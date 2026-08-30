# Dog Name Guesser

Guess the dog’s name from vibes, then optionally choose or take a photo for an on-device Vision check. Use the committee’s silly proposal or make your own accusation.

The guess, manual traits, and result persist locally. Vision reports likely image labels and proposes a silly name without uploading or saving the photo. The iOS Simulator may not provide Vision’s classifier runtime; a supported device is required for the photo-analysis path. It does not identify a real dog’s name or use a pet database; reset clears the accusation.

Camera permission is requested only after the user taps Camera. Photo-library selection uses PhotosPicker, and both paths stay on-device. There is no contacts, backend, account, analytics, ads, or network access.
