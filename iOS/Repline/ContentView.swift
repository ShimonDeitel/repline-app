import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: WorkoutSet?

    @State private var draftExercise: String = ""
    @State private var draftWeight: String = ""
    @State private var draftReps: String = ""
    @State private var draftRpe: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            WorkoutSetRow(item: item)
                                .listRowBackground(Theme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                    loadDraft(from: item)
                                    showingAdd = true
                                }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Repline")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            editingItem = nil
                            clearDraft()
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                addEditSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .tint(Theme.accent)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary)
            Text("No sets yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap + to add your first entry.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var addEditSheet: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Exercise", text: $draftExercise)
                        .accessibilityIdentifier("field_exercise")
                        .keyboardType(default)
                    TextField("Weight", text: $draftWeight)
                        .accessibilityIdentifier("field_weight")
                        .keyboardType(decimalPad)
                    TextField("Reps", text: $draftReps)
                        .accessibilityIdentifier("field_reps")
                        .keyboardType(decimalPad)
                    TextField("RPE", text: $draftRpe)
                        .accessibilityIdentifier("field_rpe")
                        .keyboardType(decimalPad)
                }
            }
            .navigationTitle(editingItem == nil ? "Add WorkoutSet" : "Edit WorkoutSet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAdd = false }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func loadDraft(from item: WorkoutSet) {
        draftExercise = item.exercise
        draftWeight = String(item.weight)
        draftReps = String(item.reps)
        draftRpe = String(item.rpe)
    }

    private func clearDraft() {
        draftExercise = ""
        draftWeight = ""
        draftReps = ""
        draftRpe = ""
    }

    private func save() {
        if let editing = editingItem {
            var updated = editing
            updated.exercise = draftExercise
            updated.weight = Double(draftWeight) ?? 0
            updated.reps = Double(draftReps) ?? 0
            updated.rpe = Double(draftRpe) ?? 0
            store.update(updated)
        } else {
            let item = WorkoutSet(exercise: draftExercise, weight: Double(draftWeight) ?? 0, reps: Double(draftReps) ?? 0, rpe: Double(draftRpe) ?? 0)
            store.add(item)
        }
        showingAdd = false
    }
}

struct WorkoutSetRow: View {
    let item: WorkoutSet

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.exercise.isEmpty ? "Untitled" : item.exercise)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text(item.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
