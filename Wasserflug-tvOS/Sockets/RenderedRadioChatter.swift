import Foundation
import SwiftUI
import FloatplaneAPIAsync
import BigNumber

struct RenderedRadioChatter: Equatable, Identifiable {
	static let usernameRegex: Regex = /\b@\w+\b/
	
	let radioChatter: RadioChatter
	let text: Text
	
	var id: String {
		radioChatter.id
	}
	
	init(radioChatter: RadioChatter, loadedEmotes: [String: LoadedEmote], selfUsername: String) {
		self.radioChatter = radioChatter
		
		// It would have been nice to use AttributedString instead of SwiftUI's Text,
		// but Text doesn't support image attachments in attributed strings.
		// Instead, we have to create a Text with an image directly, and concatenate
		// the Text instances. Doing this ahead of time once will hopefully
		// keep SwiftUI updates a bit faster.
		
		// Username
		let username = Text(verbatim: radioChatter.username)
			.foregroundColor(Self.color(for: radioChatter.username))
			.bold()
		
		// Space between username and message
		let spacer = Text("   ")

		// Process message
		// Add invisible separates into the message marking certain substrings
		// that need processing.
		// 1. Emotes
		// If a message comes in with emotes, the emotes themselves will be included
		// with the message contents as text. The emote code is surrounded by colons
		// in the message.
		// 2. Mentions
		// Mentions ("@jamamp") should be highlighted to the target's username
		// color.
		var messageContents = radioChatter.message
		// Zero-width space, valid unicode and not used much
		let messageContentSeparator: Character = "\u{200B}"
		
		// Add separators around emotes
		// Make sure to only do this for emotes the user is allowed to use,
		// not all emotes that are available.
		for emote in radioChatter.emotes ?? [] {
			if loadedEmotes[emote.code] != nil {
				let colonCode = ":" + emote.code + ":"
				let markedColonCode = "\(messageContentSeparator)\(colonCode)\(messageContentSeparator)"
				messageContents = messageContents.replacingOccurrences(of: colonCode, with: markedColonCode)
			}
		}
		
		// Use regex to add the separators around mentions
		messageContents = messageContents.replacing(Self.usernameRegex, with: { match in
			return "\(messageContentSeparator)\(match.0)\(messageContentSeparator)"
		})
		
		// Process the message string contents into concatenated Text instances
		var message: Text = Text(verbatim: "")
		for chunk in messageContents.split(separator: messageContentSeparator, omittingEmptySubsequences: true) {
			if let loadedEmote = loadedEmotes[String(chunk.dropFirst().dropLast())] {
				// Change an emote chunk to the actual image (which was
				// previously loaded and processed)
				message = message + Text(Image(uiImage: loadedEmote.image))
			} else if chunk.wholeMatch(of: Self.usernameRegex) != nil {
				// Change a mention chunk to proper color and other styling
				if chunk == "@\(selfUsername)" {
					// This highlight isn't padded with rounded corners like the
					// FP website does it, but we're hitting SwiftUI limits.
					var attributedString = AttributedString(chunk)
					attributedString[AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute.self] = .white
					attributedString[AttributeScopes.SwiftUIAttributes.BackgroundColorAttribute.self] = FPColors.blue
					message = message + Text(attributedString).bold()
				} else {
					message = message + Text(verbatim: String(chunk))
						.foregroundColor(Self.color(for: String(chunk.dropFirst())))
						.bold()
				}
			} else {
				message = message + Text(verbatim: String(chunk))
			}
		}
		
		self.text = username + spacer + message
	}
	
	/// BigNumber/BitInt calculations are slow, so cache the results.
	static var usernameHashCache: [String: Int] = [:]
	
	static func hash(username: String) -> Int64 {
		var hashCode: BInt = 0
		for c in username.utf8 {
			hashCode = BInt(c) + ((hashCode << BInt(5)) - hashCode)
		}
		hashCode %= BInt((1 << 53) - 1)
		if let limb = hashCode.rawValue.limbs.first, limb <= Int64.max {
			return Int64(limb)
		} else {
			// This is a failsafe. This should never execute.
			return 0
		}
	}

	static func color(for username: String) -> Color {
		let bound = Int64(FPColors.UsernameColors.all.count)
		
		// Use cache when possible
		if let hash = Self.usernameHashCache[username] {
			return FPColors.UsernameColors.all[hash]
		}
		
		// Calculate and populate the cache if needed
		let hash = Int(((Self.hash(username: username) % bound) + bound) % bound)
		Self.usernameHashCache[username] = hash
		return FPColors.UsernameColors.all[Int(hash)]
	}
}
