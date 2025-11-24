package name.avioli.unilinks;

import android.content.Intent;
import android.net.Uri;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class UniLinksPlugin implements FlutterPlugin, ActivityAware {

    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private Uri initialLink;
    private EventChannel.EventSink eventSink;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel = new MethodChannel(binding.getBinaryMessenger(), "uni_links/messages");
        eventChannel = new EventChannel(binding.getBinaryMessenger(), "uni_links/events");

        methodChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("getInitialLink")) {
                result.success(initialLink != null ? initialLink.toString() : null);
            } else {
                result.notImplemented();
            }
        });

        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object args, EventChannel.EventSink sink) {
                eventSink = sink;
            }

            @Override
            public void onCancel(Object args) {
                eventSink = null;
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Intent intent = binding.getActivity().getIntent();
        initialLink = intent.getData();

        binding.addOnNewIntentListener(intent1 -> {
            Uri uri = intent1.getData();
            if (uri != null && eventSink != null) {
                eventSink.success(uri.toString());
            }
            return false;
        });
    }

    @Override
    public void onDetachedFromActivity() {}

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {}
}
