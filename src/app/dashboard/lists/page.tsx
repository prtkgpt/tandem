"use client";

import { useState, useEffect } from "react";

interface ListItem {
  id: string;
  content: string;
  completed: boolean;
  createdAt: string;
}

interface List {
  id: string;
  title: string;
  icon: string;
  items: ListItem[];
  creator: {
    id: string;
    name: string;
  };
  createdAt: string;
}

const LIST_ICONS = ["📝", "🛒", "🎯", "🎬", "🍳", "✈️", "📚", "🎁", "🏋️", "🎵"];

export default function ListsPage() {
  const [lists, setLists] = useState<List[]>([]);
  const [newTitle, setNewTitle] = useState("");
  const [newIcon, setNewIcon] = useState("📝");
  const [showCreate, setShowCreate] = useState(false);
  const [showIconPicker, setShowIconPicker] = useState(false);
  const [newItemContent, setNewItemContent] = useState<Record<string, string>>(
    {}
  );
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchLists();
  }, []);

  const fetchLists = async () => {
    const res = await fetch("/api/lists");
    const data = await res.json();
    if (data.lists) setLists(data.lists);
  };

  const handleCreateList = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim()) return;
    setLoading(true);

    try {
      const res = await fetch("/api/lists", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: newTitle, icon: newIcon }),
      });

      const data = await res.json();
      if (data.list) {
        setLists([data.list, ...lists]);
        setNewTitle("");
        setNewIcon("📝");
        setShowCreate(false);
      }
    } catch (err) {
      console.error("Failed to create list:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddItem = async (listId: string) => {
    const content = newItemContent[listId];
    if (!content?.trim()) return;

    try {
      const res = await fetch(`/api/lists/${listId}/items`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ content }),
      });

      const data = await res.json();
      if (data.item) {
        setLists(
          lists.map((list) =>
            list.id === listId
              ? { ...list, items: [...list.items, data.item] }
              : list
          )
        );
        setNewItemContent({ ...newItemContent, [listId]: "" });
      }
    } catch (err) {
      console.error("Failed to add item:", err);
    }
  };

  const handleToggleItem = async (listId: string, itemId: string, completed: boolean) => {
    try {
      await fetch(`/api/lists/${listId}/items`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ itemId, completed: !completed }),
      });

      setLists(
        lists.map((list) =>
          list.id === listId
            ? {
                ...list,
                items: list.items.map((item) =>
                  item.id === itemId
                    ? { ...item, completed: !completed }
                    : item
                ),
              }
            : list
        )
      );
    } catch (err) {
      console.error("Failed to toggle item:", err);
    }
  };

  const handleDeleteItem = async (listId: string, itemId: string) => {
    try {
      await fetch(`/api/lists/${listId}/items`, {
        method: "DELETE",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ itemId }),
      });

      setLists(
        lists.map((list) =>
          list.id === listId
            ? {
                ...list,
                items: list.items.filter((item) => item.id !== itemId),
              }
            : list
        )
      );
    } catch (err) {
      console.error("Failed to delete item:", err);
    }
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="page-header flex items-center gap-2">
            <span>📋</span> Shared Lists
          </h1>
          <p className="text-gray-600 mt-1">
            Organize your life together
          </p>
        </div>
        <button
          onClick={() => setShowCreate(!showCreate)}
          className="btn-primary"
        >
          {showCreate ? "Cancel" : "+ New List"}
        </button>
      </div>

      {/* Create List Form */}
      {showCreate && (
        <div className="card mb-6">
          <form onSubmit={handleCreateList} className="space-y-4">
            <div className="flex items-center gap-3">
              <div className="relative">
                <button
                  type="button"
                  onClick={() => setShowIconPicker(!showIconPicker)}
                  className="text-3xl hover:scale-110 transition-transform"
                >
                  {newIcon}
                </button>
                {showIconPicker && (
                  <div className="absolute top-12 left-0 z-10 flex flex-wrap gap-2 p-3 bg-white rounded-xl shadow-lg border border-gray-200 w-56">
                    {LIST_ICONS.map((icon) => (
                      <button
                        key={icon}
                        type="button"
                        onClick={() => {
                          setNewIcon(icon);
                          setShowIconPicker(false);
                        }}
                        className={`text-2xl p-2 rounded-lg transition-all hover:scale-110 ${
                          newIcon === icon
                            ? "bg-rose-100"
                            : "hover:bg-gray-100"
                        }`}
                      >
                        {icon}
                      </button>
                    ))}
                  </div>
                )}
              </div>
              <input
                type="text"
                value={newTitle}
                onChange={(e) => setNewTitle(e.target.value)}
                className="input flex-1"
                placeholder="List name (e.g., Grocery List, Date Ideas)"
                required
              />
            </div>
            <div className="flex justify-end">
              <button
                type="submit"
                disabled={loading || !newTitle.trim()}
                className="btn-primary"
              >
                {loading ? "Creating..." : "Create List"}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Lists */}
      {lists.length === 0 ? (
        <div className="card text-center py-12">
          <span className="text-5xl mb-4 block">📋</span>
          <p className="text-gray-500 mb-4">
            No lists yet. Create one to get organized together!
          </p>
          <button
            onClick={() => setShowCreate(true)}
            className="btn-primary"
          >
            Create Your First List
          </button>
        </div>
      ) : (
        <div className="space-y-6">
          {lists.map((list) => {
            const completedCount = list.items.filter((i) => i.completed).length;
            const totalCount = list.items.length;
            const progress =
              totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

            return (
              <div key={list.id} className="card">
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <span className="text-2xl">{list.icon}</span>
                    <div>
                      <h2 className="section-header">{list.title}</h2>
                      <p className="text-xs text-gray-500">
                        {completedCount}/{totalCount} done · by{" "}
                        {list.creator.name}
                      </p>
                    </div>
                  </div>
                  {totalCount > 0 && (
                    <span className="text-sm font-semibold text-rose-600">
                      {Math.round(progress)}%
                    </span>
                  )}
                </div>

                {/* Progress bar */}
                {totalCount > 0 && (
                  <div className="w-full h-1.5 bg-gray-100 rounded-full mb-4 overflow-hidden">
                    <div
                      className="h-full gradient-bg rounded-full transition-all duration-500"
                      style={{ width: `${progress}%` }}
                    />
                  </div>
                )}

                {/* Items */}
                <div className="space-y-2 mb-4">
                  {list.items.map((item) => (
                    <div
                      key={item.id}
                      className="flex items-center gap-3 group"
                    >
                      <button
                        onClick={() =>
                          handleToggleItem(list.id, item.id, item.completed)
                        }
                        className={`flex h-5 w-5 shrink-0 items-center justify-center rounded-full border-2 transition-all ${
                          item.completed
                            ? "border-rose-400 bg-rose-400 text-white"
                            : "border-gray-300 hover:border-rose-400"
                        }`}
                      >
                        {item.completed && (
                          <svg
                            className="h-3 w-3"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                            strokeWidth={3}
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              d="M5 13l4 4L19 7"
                            />
                          </svg>
                        )}
                      </button>
                      <span
                        className={`flex-1 text-sm ${
                          item.completed
                            ? "text-gray-400 line-through"
                            : "text-gray-700"
                        }`}
                      >
                        {item.content}
                      </span>
                      <button
                        onClick={() => handleDeleteItem(list.id, item.id)}
                        className="opacity-0 group-hover:opacity-100 text-gray-400 hover:text-red-500 transition-all text-xs"
                      >
                        ✕
                      </button>
                    </div>
                  ))}
                </div>

                {/* Add Item */}
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={newItemContent[list.id] || ""}
                    onChange={(e) =>
                      setNewItemContent({
                        ...newItemContent,
                        [list.id]: e.target.value,
                      })
                    }
                    onKeyDown={(e) => {
                      if (e.key === "Enter") {
                        e.preventDefault();
                        handleAddItem(list.id);
                      }
                    }}
                    className="input flex-1 py-2 text-sm"
                    placeholder="Add an item..."
                  />
                  <button
                    onClick={() => handleAddItem(list.id)}
                    disabled={!newItemContent[list.id]?.trim()}
                    className="btn-secondary py-2 px-4 text-sm"
                  >
                    Add
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
