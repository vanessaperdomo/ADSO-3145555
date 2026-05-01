package com.sena.test.IService.IInventoryService;

import com.sena.test.DTO.InventoryDTO.MemoryGameItemDto;
import java.util.List;
import java.util.UUID;

public interface IMemoryGameItemService {
    List<MemoryGameItemDto> getAll();

    MemoryGameItemDto getById(UUID id);

    MemoryGameItemDto create(MemoryGameItemDto dto);

    MemoryGameItemDto update(UUID id, MemoryGameItemDto dto);

    void delete(UUID id);
}