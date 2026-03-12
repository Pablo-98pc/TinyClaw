import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor(\TaskItem.isCompleted),
        SortDescriptor(\TaskItem.dueDate)
    ]) private var tasks: [TaskItem]

    private var pendingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    TaskRow(task: task) {
                        task.isCompleted.toggle()
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .onDelete(perform: deleteTasks)
            }
            .listStyle(.plain)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(pendingCount) pending")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .overlay {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "checkmark.circle",
                        description: Text("Create tasks by chatting with TinyClaw")
                    )
                }
            }
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}
