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

    @GetMapping("")
    public ResponseEntity<Object> findAll() {
        return new ResponseEntity<Object>(userService.findAll(), HttpStatus.OK);
    }

    @PostMapping("")
    public ResponseEntity<Object> save(@RequestBody UserDto userDto) {
        userService.save(userDto);
        return new ResponseEntity<Object>("Usuario creado correctamente", HttpStatus.OK);
    }

    @GetMapping("{id}")
    public ResponseEntity<Object> findById(@PathVariable int id) {
        User user = userService.findById(id);
        return new ResponseEntity<Object>(user, HttpStatus.OK);
    }

    @GetMapping("filterbyname/{nombre}")
    public ResponseEntity<Object> filterByName(@PathVariable String nombre) {
        List<User> users = userService.filterByName(nombre);
        return new ResponseEntity<Object>(users, HttpStatus.OK);
    }

    @DeleteMapping("{id}")
    public ResponseEntity<Object> delete(@PathVariable int id) {
        userService.delete(id);
        return new ResponseEntity<Object>("Usuario eliminado", HttpStatus.OK);
    }

    @PutMapping("{id}")
    public ResponseEntity<Object> update(@PathVariable int id, @RequestBody UserDto userDto) {
        userService.update(id, userDto);
        return new ResponseEntity<Object>("Usuario actualizado correctamente", HttpStatus.OK);
    }
}