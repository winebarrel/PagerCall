import SwiftUI

struct ContentView: View {
    @ObservedObject var pagerDuty: PagerDuty

    private let dateFmt = {
        let dtfmt = DateFormatter()
        dtfmt.dateStyle = .none
        dtfmt.timeStyle = .short
        return dtfmt
    }()

    var body: some View {
        VStack {
            List {
                HStack {
                    Spacer()
                    Image(systemName: "face.smiling")
                        .imageScale(.large)
                    Text("No Incidents")
                    Spacer()
                }
            }
            .padding(.top, 5)
            HStack {
                Image(systemName: "clock.arrow.circlepath")

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
