First clone the github repository.

Then navigate to the directory OpenEarsSampleAppSwift.

Once here, open OpenEarsSampleAppSwift.xcodeproj in the xcode 9.

Press the play button to run the simulator. To have all available features of the app, run the simulator on an iPhone 7 with IOS 11 (exporting on the xcode simulator will not allow you to export to other applications and the quality of speech recognition is worse on the xcode simulator).

For best speech recognition quality be in a quiet environment because background noise significantly worsens results since the model is not trained on voices as of yet. 

Our model currently works with the following 101 words:
["a", "about", "all", "also", "and", "as", "at", "be", "because", "but", "Brad", "by", "can", "come", "could", "day", "do", "even", "find", "first", "for", "from", "get", "give", "go", "have", "he", "her", "here", "him", "his", "how", "I", "if", "in", "into", "it", "its", "just", "know", "like", "look", "make", "man", "many", "me", "more", "my", "new", "no", "not", "now", "of", "on", "one", "only", "or", "other", "our", "out", "people", "say", "see", "she", "so", "some", "take", "tell", "than", "that", "the", "their", "them", "then", "there", "these", "they", "thing", "think", "this", "those", "time", "to", "two", "up", "use", "very", "want", "way", "we", "well", "what", "when", "which", "who", "will", "with", "would", "year", "you", "your"] 
