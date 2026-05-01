package com.sena.test.IService.IInventoryService;

import com.sena.test.DTO.InventoryDTO.SupplierDto;
import java.util.List;
import java.util.UUID;

public interface ISupplierService {
    List<SupplierDto> getAll();

    SupplierDto getById(UUID id);

    SupplierDto create(SupplierDto dto);

    SupplierDto update(UUID id, SupplierDto dto);

    void delete(UUID id);
}