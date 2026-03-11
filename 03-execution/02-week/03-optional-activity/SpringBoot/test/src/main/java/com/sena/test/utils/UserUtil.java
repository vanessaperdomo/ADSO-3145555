package com.sena.test.utils;

import com.sena.test.dto.UserDto;
import com.sena.test.entity.User;
import com.sena.test.entity.Person;

public class UserUtil {

    // Convierte UserDto → User
    // Se usa cuando recibimos datos del controller para guardarlos en la base de
    // datos
    public static User dtoToEntity(UserDto dto) {

        User user = new User();

        user.setIdUser(dto.getIdUser());
        user.setUsername(dto.getUsername());
        user.setPassword(dto.getPassword());
        user.setActivo(dto.getActivo());

        // crear objeto Person con el id que viene del DTO
        Person person = new Person();
        person.setId(dto.getIdPerson());

        user.setPerson(person);

        return user;
    }

    // Convierte User → UserDto
    // Se usa cuando queremos enviar datos de la base de datos al controller
    public static UserDto entityToDto(User user) {

        UserDto dto = new UserDto();

        dto.setIdUser(user.getIdUser());
        dto.setUsername(user.getUsername());
        dto.setPassword(user.getPassword());
        dto.setActivo(user.getActivo());

        // obtener el id de la persona relacionada
        if (user.getPerson() != null) {
            dto.setIdPerson(user.getPerson().getId());
        }

        return dto;
    }

}