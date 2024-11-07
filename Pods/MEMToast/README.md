<div align="center">
  <h1 align="center">MEMToast</h1>
  <p align="center">
  This project provides a customizable <b>MEMToast View</b> system for <b>SwiftUI</b>. You can easily display temporary messages in your app, styled using custom or predefined toast styles. It also includes environment-based configuration for consistent styling throughout your app.
</p>
</div>


## Features
 **Custom Toast Styles**: Define your own styles or use predefined ones like `DefaultToastStyle` or `SnackBarToastStyle`. 
 **Environment Integration**: Set a default toast style for the entire view hierarchy using environment values. 
 **Flexible Binding Control**: Use bindings to control when to show or hide the toast.
 
 ---
## Installation 
In your Xcode project, go to the **File** menu and select **Add Packages** to integrate the MEMToast Swift package using Swift Package Manager.

## Usage
### 1. Displaying a MEMToast
To show a toast message, use the `showToast(message:isShowing:)` method on any `View`:

```swift
import SwiftUI
import MEMToast

struct ContentView: View {
    @State private var isToastVisible: Bool = false

    var body: some View {
        VStack {
            Button("Show Toast") {
                isToastVisible = true
            }
        }
        .showToast(message: "This is a custom toast!", isShowing: $isToastVisible)
    }
}
```
<h3>Default Toast</h3>
<img src="https://firebasestorage.googleapis.com/v0/b/zinstaller-97486.appspot.com/o/Default_toast.gif?alt=media&token=167bf6f6-cb9c-4f52-a615-e1392d4ac992" alt="Default toast" width="250">

<h3>Snackbar Toast</h3>
<img src="https://firebasestorage.googleapis.com/v0/b/zinstaller-97486.appspot.com/o/Snackbar_toast.gif?alt=media&token=dd28ec81-51e6-44a8-b59b-056af2d6d24e" alt="Default toast" width="250">


### 2. Applying a Custom Toast Style
You can customize how your toast looks by using different styles. Here's how to set the `DefaultToastStyle`:

```swift
import SwiftUI
import MEMToast

struct ContentView: View {
    @State private var isToastVisible: Bool = false

    var body: some View {
        VStack {
            Button("Show Toast") {
                isToastVisible = true
            }
        }
        .showToast(message: "Default style toast!", isShowing: $isToastVisible)
        .toastViewStyle(.defaultToastStyle)  // Applying default toast style
    }
}
```
### 3. Defining a Custom Toast Style
To create your own toast style, conform to the `ToastViewStyle` protocol:

```swift
import SwiftUI
import MEMToast

struct MyCustomToastStyle: ToastViewStyle {
    func makeBody(message: String?) -> some View {
        Text(message ?? "No message")
            .padding()
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

extension ToastViewStyle where Self == MyCustomToastStyle {
	static var myCustomToastStyle: MyCustomToastStyle {
		return MyCustomToastStyle()
	}
}
```
Then, apply it to your views like this:
```swift
import SwiftUI
import MEMToast

struct ContentView: View {
    @State private var isToastVisible: Bool = false

    var body: some View {
        VStack {
            Button("Show Custom Toast") {
                isToastVisible = true
            }
        }
        .showToast(message: "Custom styled toast!", isShowing: $isToastVisible)
        .toastViewStyle(.myCustomToastStyle)  // Applying custom toast style
    }
}
```

