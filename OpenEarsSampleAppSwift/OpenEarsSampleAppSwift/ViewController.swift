//
//  ViewController.swift demonstrates a large number of the API functions of the OpenEars framework in Swift 3.01
//  OpenEarsSampleAppSwift
//
//  Created by Halle Winkler on 10/15/16.
//  Copyright © 2016 Politepix UG (haftungsbeschränkt). All rights reserved.
//  http://www.politepix.com
//  Contact at http://www.politepix.com/contact
//
//  This file is licensed under the Politepix Shared Source license found in the root of the source distribution.

// **************************************************************************************************************************************************************
// **************************************************************************************************************************************************************
// **************************************************************************************************************************************************************
// IMPORTANT NOTE: Audio driver and hardware behavior is completely different between the Simulator and a real device. It is not informative to test OpenEars' accuracy on the Simulator, and please do not report Simulator-only bugs since I only actively support 
// the device driver. Please only do testing/bug reporting based on results on a real device such as an iPhone or iPod Touch. Thanks!
// **************************************************************************************************************************************************************
// **************************************************************************************************************************************************************
// **************************************************************************************************************************************************************

import UIKit

class ViewController: UIViewController, OEEventsObserverDelegate {
    
    var slt = Slt()
    var openEarsEventsObserver = OEEventsObserver()
    var fliteController = OEFliteController()
    var usingStartingLanguageModel = Bool()
    var startupFailedDueToLackOfPermissions = Bool()
    var restartAttemptsDueToPermissionRequests = Int()
    var pathToFirstDynamicallyGeneratedLanguageModel: String!
    var pathToFirstDynamicallyGeneratedDictionary: String!
    var pathToSecondDynamicallyGeneratedLanguageModel: String!
    var pathToSecondDynamicallyGeneratedDictionary: String!
    var timer: Timer!
    var prev_string = ""
    var curr_string = ""
    var curr_word = ""
    var prev_string_stack = ["temp"]
    
    
    @IBOutlet var stopButton:UIButton!
    @IBOutlet var startButton:UIButton!
    @IBOutlet var suspendListeningButton:UIButton!	
    @IBOutlet var resumeListeningButton:UIButton!	
    @IBOutlet var statusTextView:UITextView!
    @IBOutlet var heardTextView:UITextView!
    @IBOutlet var pocketsphinxDbLabel:UILabel!
    @IBOutlet var fliteDbLabel:UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.openEarsEventsObserver.delegate = self
        self.restartAttemptsDueToPermissionRequests = 0
        self.startupFailedDueToLackOfPermissions = false
        
        let languageModelGenerator = OELanguageModelGenerator()
        
        // This is the language model (vocabulary) we're going to start up with. You can replace these words with the words you want to use.
        
        let firstLanguageArray = langArray
        
        let firstVocabularyName = "FirstVocabulary"
        
        // languageModelGenerator.verboseLanguageModelGenerator = true // Uncomment me for verbose language model generator debug output to either diagnose your issue or provide information relating to language model generation when asking for help at the forums.
        // OELogging.startOpenEarsLogging() // If you encounter any issues, set this to true to get verbose logging output from OpenEars to either diagnose your issue or provide information when asking for help at the forums.
        // If you encounter any Pocketsphinx-related issues, see below (after OEPocketsphinxController.sharedInstance().setActive() is called) to see how to turn on verbose Pocketsphinx logging to either diagnose your issue or provide information when asking for help at the forums.
        
        
        
        
        
        let firstLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: firstLanguageArray, withFilesNamed: firstVocabularyName, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish")) // Change "AcousticModelEnglish" to "AcousticModelSpanish" in order to create a language model for Spanish recognition instead of English.
        
        if(firstLanguageModelGenerationError != nil) {
            print("Error while creating initial language model: \(firstLanguageModelGenerationError)")   
        } else {
            self.pathToFirstDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: firstVocabularyName) // these are convenience methods you can use to reference the file location of a language model that is known to have been created successfully.
            self.pathToFirstDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: firstVocabularyName) // these are convenience methods you can use to reference the file location of a dictionary that is known to have been created successfully.
            self.usingStartingLanguageModel = true // Just keeping track of which model we're using.
            
            // This is a model we will switch to when the user speaks "change model". The last entry, quidnunc, is an example of a word which will not be found in the lookup dictionary and will be passed to the fallback method. The fallback method is slower, so, for instance, creating a new language model from dictionary words will be pretty fast, but a model that has a lot of unusual names in it or invented/rare/recent-slang words will be slower to generate. You can use this information to give your users some UI feedback about what the expectations for wait times should be. However, on modern devices this is not expected to be a multi-second process if the vocabulary is within the supported size of 2000 words or fewer. Using "change model" as all one string in this array gives it a somewhat higher likelihood of being recognized as a phrase.
            
            let secondVocabularyName = "SecondVocabulary"
            
            let secondLanguageArray = ["Sunday",
                                       "Monday",
                                       "Tuesday",
                                       "Wednesday",
                                       "Thursday",
                                       "Friday",
                                       "Saturday",
                                       "quidnunc",
                                       "change model"]
            
            let secondLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: secondLanguageArray, withFilesNamed: secondVocabularyName, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish")) // Change "AcousticModelEnglish" to "AcousticModelSpanish" in order to create a language model for Spanish recognition instead of English.
            
            if(secondLanguageModelGenerationError != nil) {
                print("Error while creating second language model: \(secondLanguageModelGenerationError)")   
            } else {
                self.pathToSecondDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: secondVocabularyName)  // these are convenience methods you can use to reference the file location of a language model that is known to have been created successfully.
                self.pathToSecondDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: secondVocabularyName) // these are convenience methods you can use to reference the file location of a dictionary that is known to have been created successfully.
                
                do {
                    try OEPocketsphinxController.sharedInstance().setActive(true) // Setting the shared OEPocketsphinxController active is necessary before any of its properties are accessed.
                }
                catch {
                    print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
                }
                
                // OEPocketsphinxController.sharedInstance().verbosePocketSphinx = true // If you encounter any issues, set this to true to get verbose logging output from OEPocketsphinxController to either diagnose your issue or provide information when asking for help at the forums.
                
                if(!OEPocketsphinxController.sharedInstance().isListening) {
                    OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
                }
                
                // Here is some UI stuff that has nothing specifically to do with OpenEars implementation
                self.startButton.isHidden = true
                self.stopButton.isHidden = true
                self.suspendListeningButton.isHidden = true
                self.resumeListeningButton.isHidden = true   
            }            
        }
    }
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)") // Log it.
        if(hypothesis! == "change model") { // If the user says "change model", we will switch to the alternate model (which happens to be the dynamically generated model).
            
            // Here is an example of language model switching in OpenEars. Deciding on what logical basis to switch models is your responsibility.
            // For instance, when you call a customer service line and get a response tree that takes you through different options depending on what you say to it,
            // the models are being switched as you progress through it so that only relevant choices can be understood. The construction of that logical branching and 
            // how to react to it is your job OpenEars just lets you send the signal to switch the language model when you've decided it's the right time to do so.
            
            if(self.usingStartingLanguageModel) { // If we're on the starting model, switch to the dynamically generated one.
                OEPocketsphinxController.sharedInstance().changeLanguageModel(toFile: self.pathToSecondDynamicallyGeneratedLanguageModel, withDictionary:self.pathToSecondDynamicallyGeneratedDictionary)
                self.usingStartingLanguageModel = false
                
            } else { // If we're on the dynamically generated model, switch to the start model (this is an example of a trigger and method for switching models).
                OEPocketsphinxController.sharedInstance().changeLanguageModel(toFile: self.pathToFirstDynamicallyGeneratedLanguageModel, withDictionary:self.pathToFirstDynamicallyGeneratedDictionary)
                self.usingStartingLanguageModel = true
            }
        }
        
        if(prev_string_stack[0] == "") {
            heardTextView.text = ""
            prev_string = ""
            curr_string = ""
            print("hypothesis = ", hypothesis!)
            print("current_string = ", curr_string)
            print("prev_string = ", prev_string)
            
        }
        prev_string = curr_string
        prev_string_stack.append(prev_string)
        curr_word = hypothesis
        curr_string = prev_string + " " + hypothesis
        print("hypothesis = ", hypothesis!)
        print("current_string = ", curr_string)
        print("prev_string = ", prev_string)
        self.heardTextView.text = curr_string
        
        // This is how to use an available instance of OEFliteController. We're going to repeat back the command that we heard with the voice we've chosen.
        // self.fliteController.say(_:"You said \(hypothesis!)", with:self.slt)
    }
    // An optional delegate method of OEEventsObserver which informs that the interruption to the audio session ended.
    func audioSessionInterruptionDidEnd() {
        print("Local callback:  AudioSession interruption ended.") // Log it.
        self.statusTextView.text = "Status: AudioSession interruption ended." // Show it in the status box.
        // We're restarting the previously-stopped listening loop.
        if(!OEPocketsphinxController.sharedInstance().isListening){
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
            
        }
    }
    
    // An optional delegate method of OEEventsObserver which informs that the audio input became unavailable.
    func audioInputDidBecomeUnavailable() {
        print("Local callback:  The audio input has become unavailable") // Log it.
        self.statusTextView.text = "Status: The audio input has become unavailable" // Show it in the status box.
        
        if(OEPocketsphinxController.sharedInstance().isListening){
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening() // React to it by telling Pocketsphinx to stop listening since there is no available input (but only if we are listening).
            if(stopListeningError != nil) {
                print("Error while stopping listening in audioInputDidBecomeUnavailable: \(stopListeningError)")
            }
        }
        
        // An optional delegate method of OEEventsObserver which informs that the unavailable audio input became available again.
        func audioInputDidBecomeAvailable() {
            print("Local callback: The audio input is available") // Log it.
            self.statusTextView.text = "Status: The audio input is available" // Show it in the status box.
            if(!OEPocketsphinxController.sharedInstance().isListening) {
                OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false) // Start speech recognition, but only if we aren't already listening.
            }
        }
        // An optional delegate method of OEEventsObserver which informs that there was a change to the audio route (e.g. headphones were plugged in or unplugged).
        func audioRouteDidChange(toRoute newRoute: String!) {
            print("Local callback: Audio route change. The new audio route is \(newRoute)") // Log it.
            self.statusTextView.text = "Status: Audio route change. The new audio route is \(newRoute)"// Show it in the status box.
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening() // React to it by telling Pocketsphinx to stop listening since there is no available input (but only if we are listening).
            if(stopListeningError != nil) {
                print("Error while stopping listening in audioInputDidBecomeAvailable: \(stopListeningError)")
            }
        }
        
        
        
        
        if(!OEPocketsphinxController.sharedInstance().isListening) {
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false) // Start speech recognition, but only if we aren't already listening.
        }
    }
    
    // An optional delegate method of OEEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
    // This might be useful in debugging a conflict between another sound class and Pocketsphinx.
    func pocketsphinxRecognitionLoopDidStart() {
        
        print("Local callback: Pocketsphinx started.") // Log it.
        self.statusTextView.text = "Status: Pocketsphinx started." // Show it in the status box.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is now listening for speech.
    func pocketsphinxDidStartListening() {
        
        print("Local callback: Pocketsphinx is now listening.") // Log it.
        self.statusTextView.text = "Status: Pocketsphinx is now listening." // Show it in the status box.
        
        self.startButton.isHidden = true // React to it with some UI changes.
        self.stopButton.isHidden = true
        self.suspendListeningButton.isHidden = false
        self.resumeListeningButton.isHidden = true
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
    func pocketsphinxDidDetectSpeech() {
        print("Local callback: Pocketsphinx has detected speech.") // Log it.
        self.statusTextView.text = "Status: Pocketsphinx has detected speech." // Show it in the status box.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance. 
    // This was added because developers requested being able to time the recognition speed without the speech time. The processing time is the time between 
    // this method being called and the hypothesis being returned.
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Local callback: Pocketsphinx has detected a second of silence, concluding an utterance.") // Log it.
        self.statusTextView.text = "Status: Pocketsphinx has detected finished speech." // Show it in the status box.
    }
    
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most 
    // likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
    func pocketsphinxDidStopListening() {
        print("Local callback: Pocketsphinx has stopped listening.") // Log it.
        self.statusTextView.text = "Status: Pocketsphinx has stopped listening." // Show it in the status box.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
    // Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
    // in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to suspend recognition via the suspendRecognition method.
    func pocketsphinxDidSuspendRecognition() {
        print("Local callback: Pocketsphinx has suspended recognition.") // Log it.
        self.statusTextView.text = "Status: Pocketsphinx has suspended recognition." // Show it in the status box.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
    // having been suspended it is now resuming.  This can happen as a result of Flite speech completing
    // on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to resume recognition via the resumeRecognition method.
    func pocketsphinxDidResumeRecognition() {
        print("Local callback: Pocketsphinx has resumed recognition.") // Log it.
        self.statusTextView.text = "Status: Pocketsphinx has resumed recognition." // Show it in the status box.
    }
    
    // An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
    // recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
    func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        
        print("Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)")
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
    // complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
    func fliteDidStartSpeaking() {
        print("Local callback: Flite has started speaking") // Log it.
        self.statusTextView.text = "Status: Flite has started speaking." // Show it in the status box.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
    // complex interaction between sound classes.
    func fliteDidFinishSpeaking() {
        print("Local callback: Flite has finished speaking") // Log it.
        self.statusTextView.text = "Status: Flite has finished speaking." // Show it in the status box.
    }
    
    func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
        print("Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more.") // Log it.
        self.statusTextView.text = "Status: Not possible to start recognition loop." // Show it in the status box.	
    }
    
    func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
        print("Local callback: Tearing down the continuous recognition loop has failed for the reason %, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure) // Log it.
        self.statusTextView.text = "Status: Not possible to cleanly end recognition loop." // Show it in the status box.	
    }
    
    func testRecognitionCompleted() { // A test file which was submitted for direct recognition via the audio driver is done.
        print("Local callback: A test file which was submitted for direct recognition via the audio driver is done.") // Log it.
        if(OEPocketsphinxController.sharedInstance().isListening) { // If we're listening, stop listening.
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in testRecognitionCompleted: \(stopListeningError)")
            }
        }
        
    }
    /** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
    func pocketsphinxFailedNoMicPermissions() {
        print("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
        self.startupFailedDueToLackOfPermissions = true
        if(OEPocketsphinxController.sharedInstance().isListening){
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in pocketsphinxFailedNoMicPermissions: \(stopListeningError). Will try again in 10 seconds.")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
            if(!OEPocketsphinxController.sharedInstance().isListening) {
                OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false) // Start speech recognition, but only if we aren't already listening.
            }
        })
    }
    
    
    /** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a true or a false result  (will only be returned on iOS7 or later).*/
    
    func micPermissionCheckCompleted(withResult: Bool) {
        if(withResult) {
            
            self.restartAttemptsDueToPermissionRequests += 1
            if(self.restartAttemptsDueToPermissionRequests == 1 && self.startupFailedDueToLackOfPermissions) { // If we get here because there was an attempt to start which failed due to lack of permissions, and now permissions have been requested and they returned true, we restart exactly once with the new permissions.
                
                if(!OEPocketsphinxController.sharedInstance().isListening) {
                    OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false) // Start speech recognition, but only if we aren't already listening.
                }
                
                self.startupFailedDueToLackOfPermissions = false
            }
        }
        
    }
    
    
    
    // This is not OpenEars-specific stuff, just some UI behavior
    
    @IBAction func suspendListeningButtonAction() { // This is the action for the button which suspends listening without ending the recognition loop
        
        
        OEPocketsphinxController.sharedInstance().suspendRecognition()
        
        self.startButton.isHidden = true
        self.stopButton.isHidden = true
        self.suspendListeningButton.isHidden = true
        self.resumeListeningButton.isHidden = false
    }
    
    @IBAction func resumeListeningButtonAction() { // This is the action for the button which resumes listening if it has been suspended
        OEPocketsphinxController.sharedInstance().resumeRecognition()
        
        self.startButton.isHidden = true
        self.stopButton.isHidden = true
        self.suspendListeningButton.isHidden = false
        self.resumeListeningButton.isHidden = true	
    }
    
    @IBAction func stopButtonAction() { // This is the action for the button which shuts down the recognition loop.
        print("stop button")
//        if(OEPocketsphinxController.sharedInstance().isListening){
//            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
//            if(stopListeningError != nil) {
//                print("Error while stopping listening in pocketsphinxFailedNoMicPermissions: \(stopListeningError)")
//            }
//        }
//        self.startButton.isHidden = true
//        self.stopButton.isHidden = true
//        self.suspendListeningButton.isHidden = true
//        self.resumeListeningButton.isHidden = true
    }
    
    @IBAction func startButtonAction() { // This is the action for the button which starts up the recognition loop again if it has been shut down.
        print("start button")
//        if(!OEPocketsphinxController.sharedInstance().isListening) {
//            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false) // Start speech recognition, but only if we aren't already listening.
//        }
//        self.startButton.isHidden = true
//        self.stopButton.isHidden = true
//        self.suspendListeningButton.isHidden = false
//        self.resumeListeningButton.isHidden = true
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [heardTextView.text], applicationActivities: nil)
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.barButtonItem = (sender as! UIBarButtonItem)
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        heardTextView.text = ""
        curr_string = ""
        prev_string = ""
        prev_string_stack.append("")
    }
    
    
    @IBAction func undoButtonPressed(_ sender: Any) {
        if prev_string_stack.count != 0 {
            heardTextView.text = prev_string_stack.removeLast() as! String
            curr_string = prev_string
        }
        else{
            prev_string_stack.append("")
        }
    }
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        
        if let textRange = heardTextView.selectedTextRange {
            UIPasteboard.general.string = heardTextView.text(in: textRange)
            
            // if nothing is highlighted, then select all text, otherwise use the selected text
            if UIPasteboard.general.string == ""{
                heardTextView.selectedTextRange = heardTextView.textRange(from: heardTextView.beginningOfDocument, to: heardTextView.endOfDocument)
                UIPasteboard.general.string = heardTextView.text(in: heardTextView.selectedTextRange!)
            }
        }
        
        print(UIPasteboard.general.string!)
    }
    
    
    
}
