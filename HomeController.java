package com.example.app.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

    @GetMapping("/profile")
    public String home() {
        return "Hello, World! Welcome to the new Spring Boot Application.";
    }

    @GetMapping("/user")
    public String getUser() {
        return "Hello, Karteek.";
    }

}
