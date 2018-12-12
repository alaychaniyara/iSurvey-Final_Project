package project1.group1.gradeapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.google.zxing.Result;
import com.squareup.okhttp.Callback;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import java.io.IOException;

import me.dm7.barcodescanner.zxing.ZXingScannerView;

public class MainActivity extends AppCompatActivity implements ZXingScannerView.ResultHandler {

    private ZXingScannerView zXingScannerView;
    private final OkHttpClient client = new OkHttpClient();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        findViewById(R.id.btnScan).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                zXingScannerView = new ZXingScannerView(getApplicationContext());
                setContentView(zXingScannerView);
                zXingScannerView.setResultHandler(MainActivity.this);
                zXingScannerView.startCamera();
            }
        });
    }

    @Override
    protected void onPause(){
        super.onPause();
        zXingScannerView.stopCamera();
    }

    @Override
    public void handleResult(Result result) {
        MediaType JSON = MediaType.parse("application/json;charset=utf-8");
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("scannedCode",result.getText());
        RequestBody formBody = RequestBody.create(JSON,jsonObject.toString());
        final String token = result.getText();
        final Request request = new Request.Builder().url("http://10.216.74.59:3000/evaluators/authenticateUser")
                .header("Authorization","Bearer " +result.getText())//replace the ip here
                .addHeader("Content-Type","application/json")
                .post(formBody)
                .build();
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Request request, IOException e) {
                Log.d("demo", "Failed to authenticate : " + e.getMessage());
            }

            @Override
            public void onResponse(Response response) throws IOException {
                if(response.isSuccessful()){
                    final String result = response.body().string();
                    Log.d("demo", "Successful response : " + result);

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            //intent to another screen with 2 buttons
                            Intent userIntent = new Intent(MainActivity.this,UserActivity.class);
                            userIntent.putExtra("userToken",token);
                            startActivity(userIntent);
                        }
                    });
                }
            }
        });
        Toast.makeText(getApplicationContext(),result.getText(),Toast.LENGTH_SHORT).show();
        zXingScannerView.resumeCameraPreview(this);
    }
}
