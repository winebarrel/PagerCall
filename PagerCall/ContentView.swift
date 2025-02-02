import SwiftUI

struct ContentView: View {
    @ObservedObject var pagerDuty: PagerDutyModel
    @Binding var apiKey: String
    @State private var hoverId = ""

    var body: some View {
        VStack {
            if apiKey.isEmpty {
                List {
                    VStack {
                        Spacer().padding()
                        Image(nsImage: NSImage(named: "AppIcon")!)
                        Link(destination: URL(string: "https://github.com/winebarrel/PagerCall#configuration")!) {
                            Text("Set up your PagerDuty API Key.")
                        }.effectHoverCursor()
                        HStack {
                            Spacer()
                            SettingsLink {
                                Image(systemName: "gearshape")
                                Text("Settings")
                            }.preActionButtonStyle {
                                NSApp.activate(ignoringOtherApps: true)
                            }
                            Spacer()
                        }
                    }
                }
            } else if let pdErr = self.pagerDuty.error {
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
                    VStack(alignment: .leading) {
                        HStack(spacing: 2) {
                            Text(incident.urgency.rawValue)
                                .padding(.horizontal, 3)
                                .foregroundColor(.white)
                                .background(incident.urgency == .high ? .urgencyHigh : .gray, in: RoundedRectangle(cornerRadius: 5))
                            Text("on")
                            Text(incident.service.summary)
                                .fontWeight(.bold)
                        }.font(.caption)

                        HStack {
                            Link(destination: URL(string: incident.htmlUrl)!) {
                                Text(incident.title)
                                    .multilineTextAlignment(.leading)
                                    .underline(hoverId == incident.id)
                                    .onHover { hovering in
                                        hoverId = hovering ? incident.id : ""
                                    }
                                    .effectHoverCursor()
                            }
                            Text("(\(incident.createdAt.relative()))").font(.caption2)
                        }
                    }
                }
            }
            HStack {
                Button {
                    Task {
                        await pagerDuty.update(apiKey)
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }.effectHoverCursor()

                let label = if let updatedAt = pagerDuty.updatedAt {
                    updatedAt.shortTime()
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
    ContentView(
        pagerDuty: PagerDutyModel(),
        apiKey: .constant("")
    )
}
