//
//  ContentView.swift
//  MemoryGame
//
//  Created by Rista Subedi on 2/16/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game = MemoryGameViewModel()
    
    let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "134e19"), Color(hex: "062b0a")],
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .ignoresSafeArea()
        VStack {
            Text("Animal Match-Up")
                .font(.largeTitle.bold())
                .foregroundColor(.orange)
            
            Picker("Pairs", selection: $game.pairCount) {
                Text("2 Pairs").tag(2)
                Text("4 Pairs").tag(4)
                Text("6 Pairs").tag(6)
                Text("8 Pairs").tag(8)
            }
            .pickerStyle(.segmented)
            .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(game.cards.filter { !$0.isMatched }) { card in
                        CardView(card: card)
                            .aspectRatio(2/3, contentMode: .fit)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    game.choose(card)
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
            }
            Button(action: { withAnimation { game.resetGame() } }) {
                Label("Reset Journey", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
                    }

        ForEach(game.blastParticles) { particle in
            Text(particle.content)
                .font(.system(size: 50))
                .shadow(color: .white, radius: 10)
                .offset(particle.offset)
                .opacity(particle.opacity)
                .scaleEffect(particle.opacity > 0 ? 1.5 : 0.5)
        }
        
            if game.cards.count > 0 && game.cards.allSatisfy({ $0.isMatched }) {
                ZStack {
                   
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    VStack(spacing: 20) {
                        Text("🏆")
                            .font(.system(size: 100))
                            .scaleEffect(1.2)
                            
                        Text("JUNGLE KING!")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                        
                        Text("You matched all the animals!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: { withAnimation { game.resetGame() } }) {
                            Text("Play Again")
                                .fontWeight(.bold)
                                .padding()
                                .frame(width: 200)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .shadow(radius: 10)
                        }
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(hex: "062b0a"))
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.orange, lineWidth: 4))
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                .zIndex(1)
            }

    }
            .background(Color(UIColor.systemGray6).ignoresSafeArea())
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 15)
            
            if card.isFaceUp {
                shape.fill(Color.white)
                shape.strokeBorder(Color.orange, lineWidth: 4)
                Text(card.content).font(.system(size: 45))
            } else {
                shape.fill(LinearGradient(colors:[.green, Color(hex: "062b0a")],
                                          startPoint: .topLeading,
                                          endPoint: .bottomTrailing))
                shape.strokeBorder(Color.white.opacity(0.2), lineWidth: 2)
                
                Image(systemName: "leaf.fill")
                    .foregroundColor(.white.opacity(0.3))
                    .font(.title)
            }
        }
        .rotation3DEffect(.degrees(card.isFaceUp ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
