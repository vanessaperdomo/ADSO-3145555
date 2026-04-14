package com.sena.test.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.sena.test.entity.Person;
import com.sena.test.dto.PersonDto;
import com.sena.test.service.PersonService;

@RestController
@RequestMapping("/api/person")
@CrossOrigin(origins = "*") // permite conexión desde frontend
public class PersonController {

    @Autowired
    private PersonService personService;

    // =========================
    // LISTAR TODAS LAS PERSONAS
    // =========================
    @GetMapping
    public List<Person> findAll() {
        return personService.findAll();
    }

    // =========================
    // BUSCAR POR ID
    // =========================
    @GetMapping("/{id}")
    public Person findById(@PathVariable int id) {
        return personService.findById(id);
    }

    // =========================
    // FILTRAR POR NOMBRE
    // =========================
    @GetMapping("/filter/{nombre}")
    public List<Person> filterByName(@PathVariable String nombre) {
        return personService.filterByName(nombre);
    }

    // =========================
    // GUARDAR PERSONA
    // =========================
    @PostMapping
    public String save(@RequestBody PersonDto personDto) {
        return personService.save(personDto);
    }

    // =========================
    // ACTUALIZAR PERSONA
    // =========================
    @PutMapping("/{id}")
    public String update(
            @PathVariable int id,
            @RequestBody PersonDto personDto) {

        return personService.update(id, personDto);
    }

    // =========================
    // ELIMINAR PERSONA
    // =========================
    @DeleteMapping("/{id}")
    public String delete(@PathVariable int id) {
        return personService.delete(id);
    }
}