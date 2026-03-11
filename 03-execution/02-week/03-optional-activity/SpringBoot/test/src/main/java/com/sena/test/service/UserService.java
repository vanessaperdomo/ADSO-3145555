package com.sena.test.service;

import java.util.List;
import com.sena.test.entity.User;
import com.sena.test.dto.UserDto;

public interface UserService {

    public List<User> findAll(); // findal: busca todas las personas

    public User findById(int id); // findById: busca por id

    public List<User> filterByName(String nombre); // filtra por el nombre

    public String save(UserDto u); // save = guarde

    public String delete(int id); // aqui elimina por id

    public String update(int id, UserDto u); // actualizar

}
