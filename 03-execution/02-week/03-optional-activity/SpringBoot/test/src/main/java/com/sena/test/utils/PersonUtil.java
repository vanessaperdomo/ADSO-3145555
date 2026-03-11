package com.sena.test.utils;

import com.sena.test.dto.PersonDto;
import com.sena.test.entity.Person;

public class PersonUtil {

    // Convierte PersonDto → Person (para guardar en la base de datos)
    public static Person dtoToEntity(PersonDto dto) {

        Person person = new Person();

        person.setId(dto.getId());
        person.setNombre(dto.getNombre());
        person.setTelefono(dto.getTelefono());
        person.setDireccion(dto.getDireccion());
        person.setCorreo(dto.getCorreo());

        return person;
    }

    // Convierte Person → PersonDto (para enviar datos al controller)
    public static PersonDto entityToDto(Person person) {

        PersonDto dto = new PersonDto();

        dto.setId(person.getId());
        dto.setNombre(person.getNombre());
        dto.setTelefono(person.getTelefono());
        dto.setDireccion(person.getDireccion());
        dto.setCorreo(person.getCorreo());

        return dto;
    }

}