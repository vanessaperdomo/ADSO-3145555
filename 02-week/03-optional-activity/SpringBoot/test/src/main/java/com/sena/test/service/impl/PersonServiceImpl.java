package com.sena.test.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sena.test.IRepository.PersonRepository;
import com.sena.test.entity.Person;
import com.sena.test.dto.PersonDto;
import com.sena.test.service.PersonService;

@Service
public class PersonServiceImpl implements PersonService {

    @Autowired
    private PersonRepository personRepository;

    @Override
    public List<Person> findAll() {
        return this.personRepository.findAll();
    }

    @Override
    public Person findById(int id) {
        return personRepository.findById(id).orElse(null);
    }

    @Override
    public String save(PersonDto personDto) {
        Person person = dtoToEntity(personDto);
        personRepository.save(person);
        return "Person guardada exitosamente";
    }

    @Override
    public String delete(int id) {
        personRepository.deleteById(id);
        return "Person eliminada exitosamente";
    }

    @Override
    public List<Person> filterByName(String nombre) {
        return personRepository.filterByName(nombre);
    }

    public Person dtoToEntity(PersonDto personDto) {
        return new Person(
                personDto.getId(),
                personDto.getNombre(),
                personDto.getTelefono(),
                personDto.getDireccion(),
                personDto.getCorreo());
    }

    public PersonDto entityToDto(Person person) {
        return new PersonDto(
                person.getId(),
                person.getNombre(),
                person.getTelefono(),
                person.getDireccion(),
                person.getCorreo());
    }

    @Override
    public String update(int id, PersonDto p) {
        Person person = personRepository.findById(id).orElse(null);
        if (person != null) {
            person.setNombre(p.getNombre());
            person.setTelefono(p.getTelefono());
            person.setDireccion(p.getDireccion());
            person.setCorreo(p.getCorreo());
            personRepository.save(person);
            return "Persona actualizada correctamente";
        }

        return "Persona no encontrada";
    }
}