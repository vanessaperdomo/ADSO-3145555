package com.sena.test.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.sena.test.dto.RoleDto;
import com.sena.test.entity.Role;
import com.sena.test.service.RoleService;

@RestController
@RequestMapping("/role")
public class RoleController {

    @Autowired
    private RoleService roleService;

    @GetMapping("") // traer todas las personas
    public ResponseEntity<Object> findAll() {
        return new ResponseEntity<Object>(
                roleService.findAll(),
                HttpStatus.OK);
    }

    @PostMapping("") // crea una persona
    public ResponseEntity<Object> save(@RequestBody RoleDto roleDto) {
        roleService.save(roleDto);
        return new ResponseEntity<Object>("Rol creado correctamente",
                HttpStatus.OK);
    }

    @GetMapping("{id}") // la persona se busca por id
    public ResponseEntity<Object> findById(@PathVariable int id) {
        Role role = roleService.findById(id); // variable persona llama a una sola persona
        return new ResponseEntity<Object>(role, HttpStatus.OK);
    }

    @GetMapping("filterbyname/{nombre}")
    public ResponseEntity<Object> filterByName(@PathVariable String nombre) {
        List<Role> roles = roleService.filterByName(nombre); // variable personas llama a muchos
        return new ResponseEntity<Object>(roles, HttpStatus.OK);
    }

    @DeleteMapping("{id}") // elimina por id
    public ResponseEntity<Object> delete(@PathVariable int id) {
        roleService.delete(id);
        return new ResponseEntity<Object>("Rol eliminado", HttpStatus.OK);
    }

    @PutMapping("{id}") // actualiza por id
    public ResponseEntity<Object> update(@PathVariable int id, @RequestBody RoleDto roleDto) {
        roleService.update(id, roleDto);
        return new ResponseEntity<Object>(
                "Rol actualizado correctamente",
                HttpStatus.OK);
    }
}