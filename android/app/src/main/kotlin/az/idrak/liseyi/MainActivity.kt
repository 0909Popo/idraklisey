package az.idrak.liseyi

// local_auth (Face ID / Touch ID) needs a FragmentActivity to show the
// native biometric prompt; plain FlutterActivity makes authenticate() fail.
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
