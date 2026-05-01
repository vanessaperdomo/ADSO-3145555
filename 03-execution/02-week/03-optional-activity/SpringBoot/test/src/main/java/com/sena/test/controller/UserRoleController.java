package com.sena.test.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sena.test.dto.UserRoleDto;
import com.sena.test.entity.UserRole;
import com.sena.test.service.UserRoleService;

@RestController
@RequestMapping("/userrole")
@CrossOrigin(origins = "*")
public class UserRoleController {

    @Autowired
    private UserRoleService userRoleService;

    @GetMapping("")
    public ResponseEntity<Object> findAll() {
        return new ResponseEntity<Object>(userRoleService.findAll(), HttpStatus.OK);
    }

    @GetMapping("/user/{idUser}")
    public ResponseEntity<Object> findByUserId(@PathVariable Integer idUser) {
        List<UserRole> result = userRoleService.findByUserId(idUser);
        return new ResponseEntity<Object>(result, HttpStatus.OK);
    }

    @GetMapping("/role/{idRole}")
    public ResponseEntity<Object> findByRoleId(@PathVariable Integer idRole) {
        List<UserRole> result = userRoleService.findByRoleId(idRole);
        return new ResponseEntity<Object>(result, HttpStatus.OK);
    }

    @PostMapping("")
    public ResponseEntity<Object> save(@RequestBody UserRoleDto userRoleDto) {
        String msg = userRoleService.save(userRoleDto);
        return new ResponseEntity<Object>(msg, HttpStatus.OK);
    }

    @DeleteMapping("/{idUser}/{idRole}")
    public ResponseEntity<Object> delete(
            @PathVariable Integer idUser,
            @PathVariable Integer idRole) {
        String msg = userRoleService.delete(idUser, idRole);
        return new ResponseEntity<Object>(msg, HttpStatus.OK);
    }
}