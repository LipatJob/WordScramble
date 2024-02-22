//
//  ContentView.swift
//  WordScramble
//
//  Created by Job Lipat on 2/22/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var enteredWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var highScores = [Int]()
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                }
                Section("Words Guessed"){
                    ForEach(enteredWords, id: \.self){ word in
                        RowView(word: word)
                    }
                }
                Section("High Scores"){
                    ForEach(highScores, id: \.self){ highScore in
                        Text("\(highScore)")
                    }
                }
            }
            .toolbar{
                ToolbarItemGroup{
                    Button("Restart", action: {
                        recordHighScore(score: getScore())
                        startGame()
                        
                    })
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform:startGame)
            .alert(errorMessage, isPresented: $showingError)
            {
                Button("Ok", action: {})
            } message: {
                Text(errorTitle)
                VStack{
                    Text(errorMessage)
                }
            }
        }
    }
    
    func getScore() -> Int{
        return enteredWords.reduce(0, {accumulator, currentWord in return accumulator + currentWord.count})
    }
    
    func recordHighScore(score: Int){
        let MAX_HIGH_SCORE_COUNT = 5
        highScores.append(score)
        highScores = Array(highScores.sorted(by: >).prefix(MAX_HIGH_SCORE_COUNT))
    }
    
    func addNewWord(){
        let answer = newWord
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !answer.isEmpty else { return }
        
        guard isValidLength(word: answer, minLength: 3) else {
            return wordError(title: "Word too short", message: "Word needs to be longer than 3 letters")
        }
        
        guard isNotRootWord(answer) else {
            return wordError(title: "Root word entered", message: "You can't use the root word")
        }
        
        guard isOriginal(answer) else{
            return wordError(title: "Word used already", message: "Be more original")
        }
        
        guard isPossible(answer) else{
            return wordError(title: "Word not possible", message: "word cannot be spelled from the root word")
        }
        
        guard isReal(answer) else{
            return wordError(title: "Word is not real", message: "Word is not in the dictionary")
        }
        
        enteredWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func isNotRootWord(_ word: String) -> Bool{
        return word != rootWord
    }
        
    func wordError(title: String, message: String){
            self.errorTitle = title
            self.errorMessage = message
            self.showingError = true
        }
    
    func startGame(){
        enteredWords = [String]()
        rootWord = ""
        newWord = ""
        
        errorTitle = ""
        errorMessage = ""
        showingError = false
        
        guard
            let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"),
            let startWords = try? String(contentsOf: startWordsUrl)
        else {
            fatalError("Couldn't load start.txt from bundle")
        }
        
        rootWord = startWords
            .components(separatedBy: "\n")
            .randomElement() ?? "silkworm"
    }
    
    func isValidLength(word: String, minLength: Int) -> Bool{
        return word.count >= minLength
    }
    
    func isOriginal(_ word: String) -> Bool{
        return !enteredWords.contains(word)
    }
    
    func isPossible(_ word: String) -> Bool{
        let inputLetterCount = getLetterCount(word)
        let expectedLetterCount = getLetterCount(rootWord)
        
        print(inputLetterCount)
        print(expectedLetterCount)
        
        for (letter, count) in inputLetterCount{
            if
                expectedLetterCount[letter] == nil ||
                expectedLetterCount[letter]! < count
            {
                return false
            }
        }
        
        return true
    }
    
    func isReal(_ word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func getLetterCount(_ word: String) -> [Character: Int]{
        var letterCounts = [Character: Int]()
        for letter in word{
            if let val = letterCounts[letter] {
                letterCounts[letter] = val + 1
            } else {
                letterCounts[letter] = 1
            }
        }
        return letterCounts
       
    }
    
    
    
    
    
}

#Preview {
    ContentView()
}
