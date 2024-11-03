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
            if let pdErr = self.pagerDuty.error as? PagerDutyError {
                List {
                    HStack {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .imageScale(.large)
                        Text(pdErr.localizedDescription)
                        Spacer()
                    }
                }
            } else if self.pagerDuty.incidents.isEmpty {
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
                        Text(incident.urgency.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 3)
                            .foregroundColor(.white)
                            .background(incident.urgency == .high ? .urgencyHigh : .gray, in: RoundedRectangle(cornerRadius: 5))
                        Text(incident.title)
                            .multilineTextAlignment(.leading)
                            .underline(hoverId == incident.id)
                            .onHover { hovering in
                                hoverId = hovering ? incident.id : ""
                            }
                    }
                }
            }
            HStack {
                Button {
                    Task {
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
    }
}

#Preview {
    ContentView(pagerDuty: PagerDuty())
}
