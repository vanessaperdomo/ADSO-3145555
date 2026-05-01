package com.sena.test.Service.InventoryService;

import com.sena.test.DTO.InventoryDTO.InventoryMovementDto;
import com.sena.test.Entity.Inventory.InventoryMovement;
import com.sena.test.Entity.Inventory.Product;
import com.sena.test.Entity.Security.Users;
import com.sena.test.IRepository.IInventoryRepository.IInventoryMovementRepository;
import com.sena.test.IRepository.IInventoryRepository.IProductRepository;
import com.sena.test.IRepository.ISecurityRepository.IUsersRepository;
import com.sena.test.IService.IInventoryService.IInventoryMovementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class InventoryMovementService implements IInventoryMovementService {

    @Autowired
    private IInventoryMovementRepository repository;

    @Autowired
    private IProductRepository productRepository;

    @Autowired
    private IUsersRepository usersRepository;

    private InventoryMovementDto toDto(InventoryMovement e) {
        InventoryMovementDto dto = new InventoryMovementDto();
        dto.setId(e.getId());
        dto.setMovementType(e.getMovementType());
        dto.setQuantity(e.getQuantity());
        dto.setProductId(e.getProduct().getId());
        dto.setCreatedBy(e.getCreatedBy().getId());
        dto.setCreatedAt(e.getCreatedAt());
        return dto;
    }

    private InventoryMovement toEntity(InventoryMovementDto dto) {
        InventoryMovement e = new InventoryMovement();
        e.setMovementType(dto.getMovementType());
        e.setQuantity(dto.getQuantity());
        Product product = productRepository.findById(dto.getProductId()).orElse(null);
        e.setProduct(product);
        Users user = usersRepository.findById(dto.getCreatedBy()).orElse(null);
        e.setCreatedBy(user);
        return e;
    }

    @Override
    public List<InventoryMovementDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public InventoryMovementDto getById(UUID id) {
        InventoryMovement e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public InventoryMovementDto create(InventoryMovementDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}
