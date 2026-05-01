package com.sena.test.Service.InventoryService;

import com.sena.test.DTO.InventoryDTO.SupplierDto;
import com.sena.test.Entity.Inventory.Supplier;
import com.sena.test.IRepository.IInventoryRepository.ISupplierRepository;
import com.sena.test.IService.IInventoryService.ISupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class SupplierService implements ISupplierService {

    @Autowired
    private ISupplierRepository repository;

    private SupplierDto toDto(Supplier e) {
        SupplierDto dto = new SupplierDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    private Supplier toEntity(SupplierDto dto) {
        Supplier e = new Supplier();
        e.setName(dto.getName());
        return e;
    }

    @Override
    public List<SupplierDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public SupplierDto getById(UUID id) {
        Supplier e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public SupplierDto create(SupplierDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public SupplierDto update(UUID id, SupplierDto dto) {
        Supplier e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setName(dto.getName());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}