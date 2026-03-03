package com.sena.test.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.sena.test.dto.PersonDto;
import com.sena.test.entity.Person;
import com.sena.test.service.PersonService;

@RestController
@RequestMapping("/person")
public class PersonController {

    @Autowired
    private PersonService personService;

    @GetMapping("") // traer todas las personas
    public ResponseEntity<Object> findAll() {
        return new ResponseEntity<Object>(
                personService.findAll(),
                HttpStatus.OK);
    }

    @PostMapping("") // crea una persona
    public ResponseEntity<Object> save(@RequestBody PersonDto personDto) {
        personService.save(personDto);
        return new ResponseEntity<>("Persona creada correctamente",
                HttpStatus.OK);
    }

    @GetMapping("{id}") // la persona se busca por id
    public ResponseEntity<Object> findById(@PathVariable int id) {
        Person person = personService.findById(id); // variable persona llama a una sola persona
        return new ResponseEntity<Object>(person, HttpStatus.OK);
    }

    @GetMapping("filterbyname/{nombre}")
    public ResponseEntity<Object> filterByName(@PathVariable String nombre) {
        List<Person> personas = personService.filterByName(nombre); // variable personas llama a muchos
        return new ResponseEntity<Object>(personas, HttpStatus.OK);
    }

    @DeleteMapping("{id}") // elimina por id
    public ResponseEntity<Object> delete(@PathVariable int id) {
        personService.delete(id);
        return new ResponseEntity<Object>("Persona eliminada", HttpStatus.OK);
    }

    @PutMapping("{id}") // actualiza por id
    public ResponseEntity<Object> update(@PathVariable int id, @RequestBody PersonDto personDto) {
        personService.update(id, personDto);
        return new ResponseEntity<Object>(
                "Persona actualizada correctamente",
                HttpStatus.OK);
    }
}