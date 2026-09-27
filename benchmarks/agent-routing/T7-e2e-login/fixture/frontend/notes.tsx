import { useEffect, useId, useState, type FormEvent } from "react";
import { createRoot } from "react-dom/client";

type Note = { id: number; body: string };
type RailsError = { attribute: string; type: string; message: string };

function isNote(value: unknown): value is Note {
  return typeof value === "object" && value !== null &&
    typeof (value as Note).id === "number" && typeof (value as Note).body === "string";
}

function Notes() {
  const [notes, setNotes] = useState<Note[]>([]);
  const [bodyError, setBodyError] = useState<string | null>(null);
  const [failure, setFailure] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const errorId = useId();

  useEffect(() => {
    fetch("/notes.json", { headers: { Accept: "application/json" } })
      .then(async (response) => {
        if (!response.ok) throw new Error(String(response.status));
        const data: unknown = await response.json();
        setNotes(Array.isArray(data) ? data.filter(isNote) : []);
      })
      .catch(() => setFailure("Could not load notes."));
  }, []);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const body = String(new FormData(form).get("body") ?? "");
    setSaving(true);
    setBodyError(null);
    setFailure(null);
    try {
      const response = await fetch("/notes", {
        method: "POST",
        headers: { "Content-Type": "application/json", Accept: "application/json" },
        body: JSON.stringify({ note: { body } }),
      });
      if (response.status === 201) {
        const note: unknown = await response.json();
        if (isNote(note)) setNotes((current) => [...current, note]);
        form.reset();
      } else if (response.status === 422) {
        const { errors } = (await response.json()) as { errors: RailsError[] };
        const error = errors.find((candidate) => candidate.attribute === "body");
        setBodyError(error ? `Note ${error.message}` : "Could not save note.");
      } else {
        setFailure("Could not save note. Try again.");
      }
    } catch {
      setFailure("Could not save note. Try again.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <section>
      {failure && <p role="alert">{failure}</p>}
      <ul aria-label="Notes">
        {notes.map((note) => <li key={note.id}>{note.body}</li>)}
      </ul>
      <form onSubmit={submit} noValidate>
        <label htmlFor="note-body">Note</label>
        <textarea
          id="note-body"
          name="body"
          aria-invalid={bodyError ? true : undefined}
          aria-describedby={bodyError ? errorId : undefined}
        />
        {bodyError && <p id={errorId}>{bodyError}</p>}
        <button type="submit" disabled={saving}>{saving ? "Saving…" : "Add note"}</button>
      </form>
    </section>
  );
}

const root = document.getElementById("notes-root");
if (root) createRoot(root).render(<Notes />);
