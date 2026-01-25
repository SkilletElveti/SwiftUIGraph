import SwiftUI

struct ChartView: View {
    @StateObject var vm = ChartViewModel()
    
    // We remove the static 'data' let and use vm.state.values instead
    
    var body: some View {
        VStack {
            if vm.state.isLoading {
                ProgressView("Fetching Chart Data...")
                    .frame(height: 200)
            } else if let error = vm.state.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .frame(height: 200)
            } else if !vm.state.values.isEmpty {
                // Only show chart if we have data
                chart
                    .frame(height: 200)
                    .background(chartBackground)
                    .overlay (
                        charOverlay,
                        alignment: .leading
                    )
                Button("Refresh",action: {
                    Task {
                        await vm.fetchData()
                    }
                   
                })
            } else {
                Text("No data available")
                    .frame(height: 200)
            }
        }
        .task {
            Task {
                
            }
            await vm.fetchData()
        }
    }
    
    // MARK: - Computed Properties
    // These replace the logic previously held in the init()
    
    private var data: [Double] { vm.state.values }
    
    private var minY: Double { data.min() ?? 0 }
    
    private var maxY: Double { data.max() ?? 0 }
    
    private var lineColor: Color {
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        return priceChange >= 0 ? Color.green : Color.red
    }
    
    // MARK: - Subviews
    
    var charOverlay: some View {
        VStack {
            Text(maxY.formatted())
            Spacer()
            Text(((maxY + minY)/2).formatted())
            Spacer()
            Text(minY.formatted())
        }
    }
    
    var chartBackground: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    var chart: some View {
        GeometryReader { geometry in
            Path { path in
                for indexPoint in data.indices {
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(indexPoint + 1)
                    
                    let yAxis = maxY - minY
                    // Avoid division by zero if all values are the same
                    let denom = yAxis == 0 ? 1 : yAxis
                    let yPosition = (1 - CGFloat((data[indexPoint] - minY) / denom)) * geometry.size.height
                    
                    if indexPoint == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .shadow(color: lineColor, radius: 10, x: 0.0, y: 10)
            .shadow(color: lineColor.opacity(0.1), radius: 10, x: 0.0, y: 50)
        }
    }
}
