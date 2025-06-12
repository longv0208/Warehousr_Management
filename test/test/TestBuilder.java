/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

public class TestBuilder {
    public static void main(String[] args) {
        model.User user = model.User.builder()
            .username("test")
            .isActive(true)
            .build();

        System.out.println(user);
    }
}
