package com.example.employee;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class MainTest {

    @Test
    void testGetMessage() {
        assertEquals(
            "Employee Application is running!",
            Main.getMessage()
        );
    }
}