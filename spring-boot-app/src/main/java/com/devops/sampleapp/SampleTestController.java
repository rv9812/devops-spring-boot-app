package com.devops.sampleapp;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SampleTestController {

	@RequestMapping("/")
    public String index() {
        return "Welcome to Jarvis Community";
    }
}
