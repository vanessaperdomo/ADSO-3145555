package com.sena.test.service;

import java.util.List;
import com.sena.test.entity.Person;
import com.sena.test.dto.PersonDto;

public interface PersonService {

    public List<Person> findAll(); // findAll: busca todas las personas

    public Person findById(int id); // findById: busca por id

    public List<Person> filterByName(String nombre); // filtra por el nombre

    public String save(PersonDto p); // save = guarde

    public String delete(int id); // aqui elimina por id

    public String update(int id, PersonDto p); // actualizar

}
