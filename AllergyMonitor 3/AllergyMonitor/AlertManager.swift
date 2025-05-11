import AVFoundation

#if os(iOS)
func triggerAlert() {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    let systemSoundID: SystemSoundID = 1005
    AudioServicesPlaySystemSound(systemSoundID)
}
#endif
