package com.devops.sampleapp;

import org.junit.Test;
import static org.hamcrest.Matchers.equalTo;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class SampleappApplicationTests {

	@Autowired
    private MockMvc mvc;
	
	@Test
	public void getMessage() throws Exception {
		 mvc.perform(MockMvcRequestBuilders.get("/").accept(MediaType.APPLICATION_JSON))
         .andExpect(status().isOk())
         .andExpect(content().string(equalTo("Welcome to Jarvis Community")));
	}

}
