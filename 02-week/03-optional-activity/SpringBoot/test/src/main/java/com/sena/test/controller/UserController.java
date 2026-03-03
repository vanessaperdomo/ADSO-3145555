package com.sena.test.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sena.test.dto.UserDto;
import com.sena.test.entity.User;
import com.sena.test.service.UserService;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("") // traer todas las personas
    public ResponseEntity<Object> findAll() {
        return new ResponseEntity<Object>(
                userService.findAll(),
                HttpStatus.OK);
    }

    @PostMapping("") // crea una persona
    public ResponseEntity<Object> save(@RequestBody UserDto userDto) {
        userService.save(userDto);
        return new ResponseEntity<Object>("Usuario creado correctamente",
                HttpStatus.OK);
    }

    @GetMapping("{id}") // la persona se busca por id
    public ResponseEntity<Object> findById(@PathVariable int id) {
        User user = userService.findById(id); // variable persona llama a una sola persona
        return new ResponseEntity<Object>(user, HttpStatus.OK);
    }

    @GetMapping("filterbyname/{nombre}")
    public ResponseEntity<Object> filterByName(@PathVariable String nombre) {
        List<User> users = userService.filterByName(nombre); // variable personas llama a muchos
        return new ResponseEntity<Object>(users, HttpStatus.OK);
    }

    @DeleteMapping("{id}") // elimina por id
    public ResponseEntity<Object> delete(@PathVariable int id) {
        userService.delete(id);
        return new ResponseEntity<Object>("Usuario eliminado", HttpStatus.OK);
    }

    @PutMapping("{id}") // actualiza por id
    public ResponseEntity<Object> update(@PathVariable int id, @RequestBody UserDto userDto) {
        userService.update(id, userDto);
        return new ResponseEntity<Object>(
                "Usuario actualizado correctamente",
                HttpStatus.OK);
    }
}