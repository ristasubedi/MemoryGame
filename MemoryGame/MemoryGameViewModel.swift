//
//  MemoryGameViewModel.swift
//  MemoryGame
//
//  Created by Rista Subedi on 2/16/26.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp = false
    var isMatched = false
}

struct BlastParticle: Identifiable {
    let id = UUID()
    let content: String
    let angle: Double
    let speed: Double
    var opacity: Double = 1.0
    var offset: CGSize = .zero
}

class MemoryGameViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var pairCount: Int = 4 {
        didSet { resetGame() }
    }
    @Published var blastParticles: [BlastParticle] = []
    
    private var indexOfSelectedCard: Int?
    let animalCharacters = ["🦁", "🐻", "🐆", "🦉", "🐒", "🐢", "🐊", "🐉", "🦌"]

    init() { resetGame() }

    func resetGame() {
        let selectedContent = animalCharacters.shuffled().prefix(pairCount)
        let fullSet = (selectedContent + selectedContent).shuffled()
        cards = fullSet.map { Card(content: String($0)) }
        indexOfSelectedCard = nil
    }

    func choose(_ card: Card) {
        guard let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
              !cards[chosenIndex].isFaceUp,
              !cards[chosenIndex].isMatched else { return }

        if let potentialMatchIndex = indexOfSelectedCard {
            cards[chosenIndex].isFaceUp = true
            
            if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                triggerBlast(content: cards[chosenIndex].content)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut) {
                        self.cards[chosenIndex].isMatched = true
                        self.cards[potentialMatchIndex].isMatched = true
                    }
                }
                
                if cards.allSatisfy({ $0.isMatched }) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.triggerBlast(content: "✨")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.triggerBlast(content: "🍃")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.triggerBlast(content: "🎉")
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        self.cards[chosenIndex].isFaceUp = false
                        self.cards[potentialMatchIndex].isFaceUp = false
                    }
                }
            }
            indexOfSelectedCard = nil
            
        } else {
            for index in cards.indices where !cards[index].isMatched {
                cards[index].isFaceUp = false
            }
            
            cards[chosenIndex].isFaceUp = true
            indexOfSelectedCard = chosenIndex
        }
    }
    
    func triggerBlast(content: String) {
            let newParticles = (0..<12).map { i in
                BlastParticle(
                    content: content,
                    angle: Double(i) * (360.0 / 12.0),
                    speed: Double.random(in: 100...300)
                )
            }
            self.blastParticles = newParticles
            
            withAnimation(.easeOut(duration: 0.8)) {
                for i in blastParticles.indices {
                    let radians = blastParticles[i].angle * .pi / 180
                    let distance = blastParticles[i].speed
                    blastParticles[i].offset = CGSize(
                        width: cos(radians) * distance,
                        height: sin(radians) * distance
                    )
                    blastParticles[i].opacity = 0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.blastParticles.removeAll()
            }
        }
}
