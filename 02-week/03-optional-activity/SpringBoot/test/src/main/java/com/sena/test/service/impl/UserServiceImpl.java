package com.sena.test.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sena.test.IRepository.UserRepository;
import com.sena.test.entity.User;
import com.sena.test.entity.Person;
import com.sena.test.dto.UserDto;
import com.sena.test.service.UserService;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public List<User> findAll() {
        return this.userRepository.findAll();
    }

    @Override
    public User findById(int id) {
        return userRepository.findById(id).orElse(null);
    }

    @Override
    public String save(UserDto userDto) {
        User user = dtoToEntity(userDto);
        userRepository.save(user);
        return "User guardada exitosamente";
    }

    @Override
    public String delete(int id) {
        userRepository.deleteById(id);
        return "User eliminada exitosamente";
    }

    @Override
    public List<User> filterByName(String nombre) {
        return userRepository.filterByUsername(nombre);
    }

    public User dtoToEntity(UserDto userDto) {
        Person person = new Person();
        person.setId(userDto.getIdPerson());
        return new User(
                userDto.getIdUser(),
                userDto.getUsername(),
                userDto.getPassword(),
                userDto.getActivo(),
                person);
    }

    public UserDto entityToDto(User user) {
        Integer idPerson = null;
        if (user.getPerson() != null) {
            idPerson = user.getPerson().getId();
        }

        return new UserDto(
                user.getIdUser(),
                user.getUsername(),
                user.getPassword(),
                user.getActivo(),
                idPerson);
    }

    @Override
    public String update(int id, UserDto userDto) {
        User user = userRepository.findById(id).orElse(null);
        if (user != null) {
            user.setUsername(userDto.getUsername());
            user.setPassword(userDto.getPassword());
            user.setActivo(userDto.getActivo());
            userRepository.save(user);
            return "User actualizada exitosamente";
        }
        return "User no encontrada";
    }
}
