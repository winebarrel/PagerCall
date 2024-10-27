import SwiftUI

struct ContentView: View {
    @ObservedObject var pagerDuty: PagerDuty
    @State private var hoverId = ""

    private let dateFmt = {
        let dtfmt = DateFormatter()
        dtfmt.dateStyle = .none
        dtfmt.timeStyle = .short
        return dtfmt
    }()

    var body: some View {
        VStack {
            if self.pagerDuty.incidents.isEmpty {
                List {
                    HStack {
                        Spacer()
                        Image(systemName: "face.smiling")
                            .imageScale(.large)
                        Text("No Incidents")
                        Spacer()
                    }
                }
            } else {
                List(self.pagerDuty.incidents) { incident in
                    Link(destination: URL(string: incident.htmlUrl)!) {
                        Text(incident.title)
                            .multilineTextAlignment(.leading)
                            .underline(hoverId == incident.id)
                            .onHover { hovering in
                                hoverId = hovering ? incident.id : ""
                            }
                    }
                }
            }
            // .padding(.top, 5)
            HStack {
                Button {
                    Task.detached {
                        await pagerDuty.update()
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }

                let label = if let updatedAt = pagerDuty.updatedAt {
                    dateFmt.string(from: updatedAt)
                } else {
                    "-"
                }

                Text(label)
            }
            .padding(.bottom, 5)
        }
        .background(.background)
    }
}

#Preview {
    ContentView(pagerDuty: PagerDuty())
}
