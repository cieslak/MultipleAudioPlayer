# MultipleAudioPlayer

I needed to play sequential audio files in a number of places so I made a package. 

# Usage

There are 2 inits, one takes filenames from your main bundle (like "karl.caf") and one takes URLs. Both throw errors. The filename init will error out if a file is not in your bundle.

`public convenience init(filenames: [String]) throws`
`public init(fileURLs: [URL]) throws`

You can play any file, or play a random file. Upon the end of the file, the player will start the next file in the array.

`public func play(index: Int = 0)`
`public func playRandom()`

And of course you can stop playback.

`public func stop()`

That's about it.

