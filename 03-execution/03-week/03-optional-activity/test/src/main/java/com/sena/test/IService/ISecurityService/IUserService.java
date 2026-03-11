package com.sena.test.IService.ISecurityService;

import java.util.List;
import com.sena.test.DTO.SecurityDTO.UserDTO;

public interface IUserService {

    List<UserDTO> findAll();

    UserDTO findById(Long id);

    UserDTO save(UserDTO userDTO);

    UserDTO update(Long id, UserDTO userDTO);

    void delete(Long id);

    List<UserDTO> findByFirstName(String firstName);
}
