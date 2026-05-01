package com.sena.test.Controller.BillController;

import com.sena.test.DTO.BillDTO.OrdersDto;
import com.sena.test.Service.BillService.OrdersService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrdersController {

    @Autowired
    private OrdersService ordersService;

    @GetMapping
    public List<OrdersDto> getAll() {
        return ordersService.getAll();
    }

    @GetMapping("/{id}")
    public OrdersDto getById(@PathVariable UUID id) {
        return ordersService.getById(id);
    }

    @PostMapping
    public OrdersDto create(@RequestBody OrdersDto dto) {
        return ordersService.create(dto);
    }

    @PutMapping("/{id}")
    public OrdersDto update(@PathVariable UUID id, @RequestBody OrdersDto dto) {
        return ordersService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        ordersService.delete(id);
        return "Eliminado exitosamente";
    }
}