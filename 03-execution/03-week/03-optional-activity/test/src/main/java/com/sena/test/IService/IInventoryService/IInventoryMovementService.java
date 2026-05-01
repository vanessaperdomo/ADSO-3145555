package com.sena.test.IService.IInventoryService;

import com.sena.test.DTO.InventoryDTO.InventoryMovementDto;
import java.util.List;
import java.util.UUID;

public interface IInventoryMovementService {
    List<InventoryMovementDto> getAll();

    InventoryMovementDto getById(UUID id);

    InventoryMovementDto create(InventoryMovementDto dto);

    void delete(UUID id);
}