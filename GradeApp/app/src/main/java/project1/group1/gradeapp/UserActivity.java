package project1.group1.gradeapp;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import com.google.gson.JsonObject;
import com.squareup.okhttp.Callback;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import java.io.IOException;

public class UserActivity extends AppCompatActivity {

    String userToken = "";
    private final OkHttpClient client = new OkHttpClient();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user);

        if(getIntent().getExtras() != null){
            userToken = getIntent().getExtras().getString("userToken");
        }
        
        findViewById(R.id.btnViewTeams).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                fetchTeams(userToken);
            }
        });
    }

    private void fetchTeams(String userToken) {
        MediaType JSON = MediaType.parse("application/json;charset=utf-8");
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("scannedCode",userToken);
        RequestBody formBody = RequestBody.create(JSON,jsonObject.toString());
        final Request request = new Request.Builder().url("http://192.168.0.1:3000/evaluators/teamsList")
                .header("Authorization","Bearer " +userToken)//replace the ip here
                .addHeader("Content-Type","application/json")
                .build();
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Request request, IOException e) {
                Log.d("demo", "Failure fetching teams list : " + e.getMessage());
            }

            @Override
            public void onResponse(Response response) throws IOException {
                if(response.isSuccessful()){

                }
            }
        });
    }
}
