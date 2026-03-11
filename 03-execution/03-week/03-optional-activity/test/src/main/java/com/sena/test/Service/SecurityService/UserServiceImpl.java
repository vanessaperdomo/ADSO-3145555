package com.sena.test.Service.SecurityService;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sena.test.DTO.SecurityDTO.UserDTO;
import com.sena.test.Entity.Security.Role;
import com.sena.test.Entity.Security.TrainingGroup;
import com.sena.test.Entity.Security.User;
import com.sena.test.IRepository.ISecurityRepository.IUserRepository;
import com.sena.test.IService.ISecurityService.IUserService;

@Service
public class UserServiceImpl implements IUserService {

    @Autowired
    private IUserRepository userRepository;

    private UserDTO mapToDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setEmail(user.getEmail());
        dto.setPassword(user.getPassword());
        dto.setRoleId(user.getRole() != null ? user.getRole().getId() : 0);
        dto.setGroupId(user.getGroup() != null ? user.getGroup().getId() : 0);
        dto.setIsActive(user.getIsActive());
        dto.setCreatedAt(user.getCreatedAt());
        return dto; // devuelve DTO
    }

    private User mapToEntity(UserDTO dto) {
        User user = new User();
        user.setFirstName(dto.getFirstName());
        user.setLastName(dto.getLastName());
        user.setEmail(dto.getEmail());
        user.setPassword(dto.getPassword());

        Role role = new Role();
        role.setId(dto.getRoleId());
        user.setRole(role); // asigna rol

        TrainingGroup group = new TrainingGroup();
        group.setId(dto.getGroupId());
        user.setGroup(group); // asigna grupo

        user.setIsActive(dto.getIsActive());
        user.setCreatedAt(dto.getCreatedAt());
        return user; // devuelve entidad lista para guardar
    }

    @Override
    public List<UserDTO> findAll() {
        List<UserDTO> result = new ArrayList<>();
        for (User u : userRepository.findAll()) {
            result.add(mapToDTO(u));
        }
        return result; // devuelve todos los usuarios
    }

    @Override
    public UserDTO findById(Long id) {
        User user = userRepository.findById(id).orElse(null);
        return user != null ? mapToDTO(user) : null; // busca por id
    }

    @Override
    public UserDTO save(UserDTO dto) {
        return mapToDTO(userRepository.save(mapToEntity(dto))); // guarda nuevo usuario
    }

    @Override
    public UserDTO update(Long id, UserDTO dto) {
        User user = userRepository.findById(id).orElse(null);
        if (user == null)
            return null;

        user.setFirstName(dto.getFirstName());
        user.setLastName(dto.getLastName());
        user.setEmail(dto.getEmail());
        user.setPassword(dto.getPassword());

        Role role = new Role();
        role.setId(dto.getRoleId());
        user.setRole(role);

        TrainingGroup group = new TrainingGroup();
        group.setId(dto.getGroupId());
        user.setGroup(group);

        user.setIsActive(dto.getIsActive());

        return mapToDTO(userRepository.save(user)); // guarda cambios
    }

    @Override
    public void delete(Long id) {
        userRepository.deleteById(id); // elimina por id
    }

    @Override
    public List<UserDTO> findByFirstName(String firstName) {
        List<UserDTO> result = new ArrayList<>();
        for (User u : userRepository.findByFirstName(firstName)) {
            result.add(mapToDTO(u));
        }
        return result; // filtra por nombre
    }
}