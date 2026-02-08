import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { DynamicBorder } from "@mariozechner/pi-coding-agent";
import {
	Container,
	fuzzyFilter,
	getEditorKeybindings,
	Input,
	SelectList,
	Spacer,
	Text,
	truncateToWidth,
	visibleWidth,
	type SelectItem,
} from "@mariozechner/pi-tui";

type StashItem = {
	id: string;
	text: string;
	createdAt: number;
};

type StashSnapshot = {
	version: 1;
	items: StashItem[];
};

const CUSTOM_TYPE = "prompt-stash";

const naturalRelativeTime = (timestamp: number): string => {
	const now = Date.now();
	let delta = Math.max(0, now - timestamp);
	const sec = Math.floor(delta / 1000);
	if (sec < 10) return "just now";
	if (sec < 60) return `${sec}s ago`;
	const min = Math.floor(sec / 60);
	if (min < 60) return `${min}m ago`;
	const hr = Math.floor(min / 60);
	if (hr < 24) return `${hr}h ago`;
	const day = Math.floor(hr / 24);
	if (day === 1) return "yesterday";
	if (day < 7) return `${day}d ago`;
	const wk = Math.floor(day / 7);
	if (wk < 5) return `${wk}w ago`;
	const mo = Math.floor(day / 30);
	if (mo < 12) return `${mo}mo ago`;
	const yr = Math.floor(day / 365);
	return `${yr}y ago`;
};

class StashSelectList {
	private items: SelectItem[];
	private selectedIndex = 0;
	private maxVisible: number;
	private theme: {
		selectedText: (text: string) => string;
		description: (text: string) => string;
		noMatch: (text: string) => string;
		scrollInfo: (text: string) => string;
	};

	public onSelect?: (item: SelectItem) => void;
	public onCancel?: () => void;

	constructor(items: SelectItem[], maxVisible: number, theme: StashSelectList["theme"]) {
		this.items = items;
		this.maxVisible = maxVisible;
		this.theme = theme;
	}

	replaceItems(items: SelectItem[]): void {
		this.items = items;
		this.selectedIndex = 0;
	}

	render(width: number): string[] {
		const lines: string[] = [];
		if (this.items.length === 0) {
			lines.push(this.theme.noMatch("  No matching stashes"));
			return lines;
		}

		const startIndex = Math.max(
			0,
			Math.min(this.selectedIndex - Math.floor(this.maxVisible / 2), this.items.length - this.maxVisible),
		);
		const endIndex = Math.min(startIndex + this.maxVisible, this.items.length);

		for (let i = startIndex; i < endIndex; i += 1) {
			const item = this.items[i];
			if (!item) continue;

			const isSelected = i === this.selectedIndex;
			const prefix = isSelected ? "→ " : "  ";
			const timeText = item.description ? item.description.replace(/[\r\n]+/g, " ") : "";
			const timeWidth = timeText ? visibleWidth(timeText) + 1 : 0;
			const available = Math.max(1, width - prefix.length - timeWidth - 1);
			const label = truncateToWidth(item.label || item.value, available, "");
			const padding = " ".repeat(Math.max(1, available - visibleWidth(label)));
			const line = `${prefix}${label}${padding}${timeText ? " " + timeText : ""}`;

			if (isSelected) {
				lines.push(this.theme.selectedText(line));
			} else if (timeText) {
				const base = `${prefix}${label}${padding}`;
				lines.push(base + this.theme.description(timeText ? " " + timeText : ""));
			} else {
				lines.push(line);
			}
		}

		if (startIndex > 0 || endIndex < this.items.length) {
			const scrollText = `  (${this.selectedIndex + 1}/${this.items.length})`;
			lines.push(this.theme.scrollInfo(truncateToWidth(scrollText, width - 2, "")));
		}

		return lines;
	}

	handleInput(keyData: string): void {
		const kb = getEditorKeybindings();
		if (kb.matches(keyData, "selectUp")) {
			this.selectedIndex = this.selectedIndex === 0 ? this.items.length - 1 : this.selectedIndex - 1;
		} else if (kb.matches(keyData, "selectDown")) {
			this.selectedIndex = this.selectedIndex === this.items.length - 1 ? 0 : this.selectedIndex + 1;
		} else if (kb.matches(keyData, "selectConfirm")) {
			const selected = this.items[this.selectedIndex];
			if (selected && this.onSelect) this.onSelect(selected);
		} else if (kb.matches(keyData, "selectCancel")) {
			if (this.onCancel) this.onCancel();
		}
	}
}

const showActionSelector = async (
	ctx: any,
): Promise<"restore_keep" | "restore_delete" | "view" | "delete" | null> => {
	const actions: SelectItem[] = [
		{ value: "restore_keep", label: "Restore (keep stash)" },
		{ value: "restore_delete", label: "Restore (delete stash)" },
		{ value: "view", label: "View full prompt" },
		{ value: "delete", label: "Delete" },
	];

	return ctx.ui.custom<"restore_keep" | "restore_delete" | "view" | "delete" | null>((tui, theme, _kb, done) => {
		const container = new Container();
		container.addChild(new DynamicBorder((str: string) => theme.fg("accent", str)));
		container.addChild(new Text(theme.fg("accent", theme.bold(" Choose action")), 0, 0));

		const selectList = new SelectList(actions, actions.length, {
			selectedPrefix: (text) => theme.fg("accent", text),
			selectedText: (text) => theme.fg("accent", text),
			description: (text) => theme.fg("muted", text),
			scrollInfo: (text) => theme.fg("dim", text),
			noMatch: (text) => theme.fg("warning", text),
		});

		selectList.onSelect = (item) => done(item.value as "restore_keep" | "restore_delete" | "view" | "delete");
		selectList.onCancel = () => done(null);

		container.addChild(selectList);
		container.addChild(new Text(theme.fg("dim", "Press enter to confirm or esc to cancel"), 0, 0));
		container.addChild(new DynamicBorder((str: string) => theme.fg("accent", str)));

		return {
			render(width: number) {
				return container.render(width);
			},
			invalidate() {
				container.invalidate();
			},
			handleInput(data: string) {
				selectList.handleInput(data);
				tui.requestRender();
			},
		};
	});
};

const viewStash = async (ctx: any, text: string): Promise<void> => {
	await ctx.ui.editor("Stash (read-only)", text);
};

export default function (pi: ExtensionAPI) {
	let items: StashItem[] = [];

	const saveSnapshot = () => {
		const snapshot: StashSnapshot = { version: 1, items };
		pi.appendEntry(CUSTOM_TYPE, snapshot);
	};

	const updateStatus = (ctx: any) => {
		if (!ctx?.hasUI) return;
		ctx.ui.setStatus(
			"prompt-stash",
			items.length ? ctx.ui.theme.fg("dim", `stash: ${items.length}`) : undefined,
		);
	};

	// Restore state on session load (/resume) and /reload
	pi.on("session_start", async (_event, ctx) => {
		items = [];
		for (const entry of ctx.sessionManager.getEntries()) {
			if (entry.type === "custom" && entry.customType === CUSTOM_TYPE) {
				const data = entry.data as Partial<StashSnapshot> | undefined;
				if (data?.version === 1 && Array.isArray((data as any).items)) {
					items = (data as any).items as StashItem[];
				}
			}
		}
		updateStatus(ctx);
	});

	const stashHandler = async (ctx: any) => {
		if (!ctx.hasUI) return;
		const text = ctx.ui.getEditorText() ?? "";
		if (!text.trim()) {
			ctx.ui.notify("Nothing to stash (editor empty).", "info");
			return;
		}

		items = [
			{
				id: `${Date.now()}-${Math.random().toString(16).slice(2)}`,
				text,
				createdAt: Date.now(),
			},
			...items,
		];
		saveSnapshot();

		ctx.ui.setEditorText("");
		updateStatus(ctx);
		ctx.ui.notify(`Stashed (${items.length} total).`, "info");
	};

	pi.registerShortcut("alt+s", {
		description: "Stash editor text (clears editor)",
		handler: stashHandler,
	});

	pi.registerCommand("stashed-prompts", {
		description: "Browse stashed prompts (picker). Stash with Alt+S",
		handler: async (_args, ctx) => {
			if (!ctx.hasUI) return;
			if (items.length === 0) {
				ctx.ui.notify("No stashed prompts.", "info");
				return;
			}

			const selectItems: SelectItem[] = items.map((item) => ({
				value: item.id,
				label: item.text.trim().split("\n")[0]?.slice(0, 200) || "(empty)",
				description: naturalRelativeTime(item.createdAt),
			}));

			const selectedId = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
				const container = new Container();
				container.addChild(new DynamicBorder((str: string) => theme.fg("accent", str)));
				container.addChild(new Text(theme.fg("accent", theme.bold(" Stashed prompts (Alt+S to stash)")), 0, 0));

				const searchInput = new Input();
				container.addChild(searchInput);
				container.addChild(new Spacer(1));

				const listContainer = new Container();
				container.addChild(listContainer);
				container.addChild(new Text(theme.fg("dim", "Type to filter stashed prompts • enter select • esc cancel"), 0, 0));
				container.addChild(new DynamicBorder((str: string) => theme.fg("accent", str)));

				let filtered = selectItems;
				let list: StashSelectList | null = null;

				const updateList = () => {
					listContainer.clear();
					if (filtered.length === 0) {
						listContainer.addChild(new Text(theme.fg("warning", "  No matching stashes"), 0, 0));
						list = null;
						return;
					}

					list = new StashSelectList(filtered, Math.min(filtered.length, 12), {
						selectedText: (text) => theme.fg("accent", text),
						description: (text) => theme.fg("dim", text),
						scrollInfo: (text) => theme.fg("dim", text),
						noMatch: (text) => theme.fg("warning", text),
					});

					list.onSelect = (item) => done(item.value as string);
					list.onCancel = () => done(null);
					listContainer.addChild(list);
				};

				const applyFilter = () => {
					const query = searchInput.getValue();
					filtered = query
						? fuzzyFilter(selectItems, query, (it) => `${it.label} ${it.description ?? ""}`)
						: selectItems;
					if (list) {
						list.replaceItems(filtered);
					} else {
						updateList();
					}
				};

				updateList();

				return {
					render(width: number) {
						return container.render(width);
					},
					invalidate() {
						container.invalidate();
					},
					handleInput(data: string) {
						const kb = getEditorKeybindings();
						if (
							kb.matches(data, "selectUp") ||
							kb.matches(data, "selectDown") ||
							kb.matches(data, "selectConfirm") ||
							kb.matches(data, "selectCancel")
						) {
							if (list) {
								list.handleInput(data);
							} else if (kb.matches(data, "selectCancel")) {
								done(null);
							}
							tui.requestRender();
							return;
						}

						searchInput.handleInput(data);
						applyFilter();
						tui.requestRender();
					},
				};
			});

			if (!selectedId) return;

			const index = items.findIndex((it) => it.id === selectedId);
			if (index < 0) return;

			const selected = items[index];
			if (!selected) return;

			while (true) {
				const action = await showActionSelector(ctx);
				if (!action) return;

				if (action === "view") {
					await viewStash(ctx, selected.text);
					continue;
				}

				if (action === "restore_keep") {
					ctx.ui.setEditorText(selected.text);
					updateStatus(ctx);
					ctx.ui.notify(`Restored stashed prompt (kept). (${items.length} total)`, "info");
					return;
				}

				if (action === "delete") {
					items.splice(index, 1);
					saveSnapshot();
					updateStatus(ctx);
					ctx.ui.notify("Deleted stashed prompt.", "info");
					return;
				}

				items.splice(index, 1);
				saveSnapshot();
				ctx.ui.setEditorText(selected.text);
				updateStatus(ctx);
				ctx.ui.notify(`Restored stashed prompt (deleted). (${items.length} remaining)`, "info");
				return;
			}
		},
	});
}
