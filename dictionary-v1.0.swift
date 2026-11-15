// dictionary.swift
// Stockage : un seul tableau "words" de struct Entry (english, french).
// Chaque paire est donc rangée ensemble : un mot anglais et sa traduction française.
// Recherche anglaise : parcours le tableau et  compare le champ english.
// Recherche française : même parcours, mais compare le champ french.
// Fichier : une paire par ligne, "english;french", relue ligne par ligne au chargement.

import Foundation
struct Entry {
    var english: String
    var french: String
}
var words: [Entry] = []
let fileName: String = "dictionary.txt"
func ask() -> String {
    let line = readLine()
    if line == nil { return "" }
    return line!
}
func loadWords() {
    words = []
    let text = try? String(contentsOfFile: fileName, encoding: .utf8)
    if text != nil {
        let lines = text!.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: ";", omittingEmptySubsequences: false)
            if parts.count == 2 {
                words.append(Entry(english: String(parts[0]), french: String(parts[1])))
            }
        }
    }
    print("Loaded: \(words.count) words")
}
func saveWords() {
    var content: String = ""
    for entry in words {
        content += entry.english + ";" + entry.french + "\n"
    }
    try? content.write(toFile: fileName, atomically: true, encoding: .utf8)
    print("Saved: \(words.count) words")
}
func sortedIndexes(_ french: Bool) -> [Int] {
    var idx: [Int] = []
    var i: Int = 0
    while i < words.count {
        idx.append(i)
        i += 1
    }
    var swap: Bool = true
    while swap {
        swap = false
        var j: Int = 0
        while j < idx.count - 1 {
            var a: String = words[idx[j]].english.lowercased()
            var b: String = words[idx[j + 1]].english.lowercased()
            if french {
                a = words[idx[j]].french.lowercased()
                b = words[idx[j + 1]].french.lowercased()
            }
            if a > b {
                let temp: Int = idx[j]
                idx[j] = idx[j + 1]
                idx[j + 1] = temp
                swap = true
            }
            j += 1
        }
    }
    return idx
}
func showList() {
    let pageSize: Int = 5
    var french: Bool = false
    var page: Int = 0
    var open: Bool = true
    while open {
        let idx = sortedIndexes(french)
        if french {
            print("Order: French")
        } else {
            print("Order: English")
        }
        if idx.count == 0 {
            print("(empty)")
        }
        var k: Int = page * pageSize
        while k < idx.count && k < (page + 1) * pageSize {
            let e = words[idx[k]]
            if french {
                print("\(e.french): \(e.english)")
            } else {
                print("\(e.english): \(e.french)")
            }
            k += 1
        }
        print("N next  P previous  O order  Enter closes")
        let key = ask().lowercased()
        if key == "" {
            open = false
        } else if key == "n" {
            if (page + 1) * pageSize < idx.count { page += 1 }
        } else if key == "p" {
            if page > 0 { page -= 1 }
        } else if key == "o" {
            french = !french
            page = 0
        }
    }
}
func findWord(_ word: String, _ isEnglish: Bool) -> Int {
    let target = word.lowercased()
    var found: Int = -1
    var i: Int = 0
    while i < words.count && found == -1 {
        var current: String = words[i].french.lowercased()
        if isEnglish { current = words[i].english.lowercased() }
        if current == target { found = i }
        i += 1
    }
    return found
}
func lookUp(_ isEnglish: Bool) {
    print("Word?")
    let word = ask()
    if word == "" { return }
    let pos = findWord(word, isEnglish)
    if pos != -1 {
        var translation: String = words[pos].english
        if isEnglish { translation = words[pos].french }
        print("\(word): \(translation)")
        print("Change it? (y/n)")
        if ask().lowercased() == "y" {
            print("New translation?")
            let newValue = ask()
            if newValue != "" {
                if isEnglish {
                    words[pos].french = newValue
                } else {
                    words[pos].english = newValue
                }
                print("Changed \(word): \(newValue)")
            }
        }
    } else {
        print("Translation of \(word)?")
        let translation = ask()
        if translation != "" {
            if isEnglish {
                words.append(Entry(english: word, french: translation))
            } else {
                words.append(Entry(english: translation, french: word))
            }
            print("Added \(word): \(translation)")
        }
    }
}
var running: Bool = true
while running {
    print("1. Load dictionary")
    print("2. Save dictionary")
    print("3. List")
    print("4. Look up English word")
    print("5. Look up French word")
    print("0. Quit")
    let line = readLine()
    var choice: String = "0"
    if line != nil { choice = line! }
    if choice == "1" {
        loadWords()
    } else if choice == "2" {
        saveWords()
    } else if choice == "3" {
        showList()
    } else if choice == "4" {
        lookUp(true)
    } else if choice == "5" {
        lookUp(false)
    } else if choice == "0" {
        print("Dictionary: \(words.count) words")
        running = false
    }
}