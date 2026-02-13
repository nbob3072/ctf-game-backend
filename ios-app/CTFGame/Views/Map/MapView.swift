import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // SF default
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedFlag: Flag?
    @State private var showingFlagDetail = false
    @State private var trackingMode: MapUserTrackingMode = .follow
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,
                annotationItems: mapViewModel.flags) { flag in
                MapAnnotation(coordinate: flag.coordinate) {
                    FlagMarker(flag: flag)
                        .onTapGesture {
                            selectedFlag = flag
                            showingFlagDetail = true
                        }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                // Center on user location if available
                if let userLoc = mapViewModel.userLocation {
                    region.center = userLoc
                }
            }
            .onChange(of: mapViewModel.userLocation?.latitude) { oldValue, newValue in
                updateRegionFromUserLocation()
            }
            .onChange(of: mapViewModel.userLocation?.longitude) { oldValue, newValue in
                updateRegionFromUserLocation()
            }
            
            // Top overlay - Stats bar
            VStack {
                HStack {
                    // User level and XP
                    if let user = AuthViewModel().currentUser {
                        HStack(spacing: 10) {
                            Text("Lv \(user.level)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(user.team?.colorValue ?? .gray)
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(user.xp) XP")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                
                                ProgressView(value: user.xpProgress)
                                    .tint(user.team?.colorValue ?? .gray)
                                    .frame(width: 100)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Refresh button
                    Button(action: {
                        mapViewModel.loadNearbyFlags()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Spacer()
            }
            
            // Bottom overlay - Flag count
            VStack {
                Spacer()
                
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.white)
                    Text("\(mapViewModel.flags.count) flags nearby")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .padding(.bottom, 20)
            }
            
            // Loading indicator
            if mapViewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView("Loading flags...")
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingFlagDetail) {
            if let flag = selectedFlag {
                FlagDetailView(flag: flag)
            }
        }
    }
    
    private func updateRegionFromUserLocation() {
        if let location = mapViewModel.userLocation {
            withAnimation {
                region.center = location
            }
        }
    }
}

struct FlagMarker: View {
    let flag: Flag
    @EnvironmentObject var mapViewModel: MapViewModel
    
    var body: some View {
        ZStack {
            // Pulse animation if capturable
            if mapViewModel.canCaptureFlag(flag) {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
            }
            
            // Flag marker
            VStack(spacing: 0) {
                // Flag icon
                ZStack {
                    Circle()
                        .fill(Color(hex: flag.teamColor) ?? .gray)
                        .frame(width: 32, height: 32)
                        .shadow(radius: 4)
                    
                    Text(flag.type.emoji)
                        .font(.system(size: 16))
                }
                
                // Pin stem
                Rectangle()
                    .fill(Color(hex: flag.teamColor) ?? .gray)
                    .frame(width: 2, height: 8)
            }
        }
        .onAppear {
            if mapViewModel.canCaptureFlag(flag) {
                pulseAnimation = true
            }
        }
    }
    
    @State private var pulseAnimation = false
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(MapViewModel())
    }
}
