using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;
using ProyectoDS1.Models;
using System.Data;

namespace ProyectoDS1.Controllers
{
    public class TicketsController : Controller
    {
        private readonly IConfiguration _config;

        public TicketsController(IConfiguration config)
        {
            _config = config;
        }

        // LISTAR TICKETS
        private async Task<IEnumerable<Ticket>> listarTickets()
        {
            var lista = new List<Ticket>();

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ListarTickets", cn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader dr = await cmd.ExecuteReaderAsync())
                    {
                        while (await dr.ReadAsync())
                        {
                            lista.Add(new Ticket
                            {
                                IdTicket = dr.GetInt32(0),
                                Titulo = dr.GetString(1),
                                FechaCreacion = dr.GetDateTime(2),
                                UsuarioCreador = dr.GetString(3),
                                Estado = dr.GetString(4),
                                Prioridad = dr.GetString(5),
                                Categoria = dr.GetString(6)
                            });
                        }
                    }
                }
            }
            return lista;
        }

        // BUSCAR TICKET
        private async Task<Ticket?> buscarTicket(int id)
        {
            Ticket? ticket = null;

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();
                SqlCommand cmd = new SqlCommand("usp_BuscarTicket", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@IdTicket", id);

                using (SqlDataReader dr = await cmd.ExecuteReaderAsync())
                {
                    if (await dr.ReadAsync())
                    {
                        ticket = new Ticket
                        {
                            IdTicket = dr.GetInt32(0),
                            Titulo = dr.GetString(1),
                            Descripcion = dr.GetString(2),
                            FechaCreacion = dr.GetDateTime(3),
                            FechaCierre = dr.IsDBNull(4) ? null : dr.GetDateTime(4),
                            UsuarioCreador = dr.GetString(5),
                            Estado = dr.GetString(6),
                            Prioridad = dr.GetString(7),
                            Categoria = dr.GetString(8)
                        };
                    }
                }
            }
            return ticket;
        }

        //Listar Prioridades
        private async Task<IEnumerable<SelectListItem>> listarPrioridades()
        {
            var lista = new List<SelectListItem>();

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();
                SqlCommand cmd = new SqlCommand("usp_ListarPrioridades", cn);
                using var dr = await cmd.ExecuteReaderAsync();

                while (await dr.ReadAsync())
                {
                    lista.Add(new SelectListItem
                    {
                        Value = dr.GetInt32(0).ToString(),
                        Text = dr.GetString(1)
                    });
                }
            }
            return lista;
        }

        //Listar Categorias
        private async Task<IEnumerable<SelectListItem>> listarCategorias()
        {
            var lista = new List<SelectListItem>();

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();
                SqlCommand cmd = new SqlCommand("usp_ListarCategorias", cn);
                using var dr = await cmd.ExecuteReaderAsync();

                while (await dr.ReadAsync())
                {
                    lista.Add(new SelectListItem
                    {
                        Value = dr.GetInt32(0).ToString(),
                        Text = dr.GetString(1)
                    });
                }
            }
            return lista;
        }

        //Listar Estados
        private async Task<IEnumerable<SelectListItem>> listarEstados()
        {
            var lista = new List<SelectListItem>();

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();
                SqlCommand cmd = new SqlCommand("usp_ListarEstados", cn);
                using var dr = await cmd.ExecuteReaderAsync();

                while (await dr.ReadAsync())
                {
                    lista.Add(new SelectListItem
                    {
                        Value = dr.GetInt32(0).ToString(),
                        Text = dr.GetString(1)
                    });
                }
            }
            return lista;
        }

        //CAMBIAR ESTADO
        [HttpPost]
        public async Task<IActionResult> CambiarEstado(int IdTicket, int NuevoEstado)
        {
            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                SqlCommand cmd = new SqlCommand("usp_CambiarEstadoTicket", cn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@IdTicket", IdTicket);
                cmd.Parameters.AddWithValue("@NuevoEstado", NuevoEstado);

                // por ahora simulamos usuario
                cmd.Parameters.AddWithValue("@IdUsuario", 1);

                await cn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
            }

            TempData["Success"] = "Estado actualizado correctamente";

            return RedirectToAction("ListTickets");
        }

        //LISTAR HISTORIAL DE TICJET
        private async Task<IEnumerable<HistorialTicket>> listarHistorial(int idTicket)
        {
            var lista = new List<HistorialTicket>();

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();

                SqlCommand cmd = new SqlCommand("usp_ListarHistorialTicket", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@IdTicket", idTicket);

                using (SqlDataReader dr = await cmd.ExecuteReaderAsync())
                {
                    while (await dr.ReadAsync())
                    {
                        lista.Add(new HistorialTicket
                        {
                            FechaCambio = dr.GetDateTime(0),
                            Usuario = dr.GetString(1),
                            DescripcionCambio = dr.GetString(2),
                        });
                    }
                }
            }

            return lista;
        }


        // VISTA LISTADO
        public async Task<IActionResult> ListTickets()
        {
            var tickets = await listarTickets();
            return View(tickets);
        }

        //VISTA DETALLE
        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            var ticket = await buscarTicket(id);
            if (ticket == null)
                return NotFound();

            ViewBag.Historial = await listarHistorial(id);
            return View(ticket);
        }

        //GET CREAR
        [HttpGet]
        public async Task<IActionResult> Create()
        {
            ViewBag.Prioridades = await listarPrioridades();
            ViewBag.Categorias = await listarCategorias();
            ViewBag.Estados = await listarEstados();
            return View(new Ticket());
        }

        //POST CREATE
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Ticket reg)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.Prioridades = await listarPrioridades();
                ViewBag.Categorias = await listarCategorias();
                ViewBag.Estados = await listarEstados();
                return View(reg);
            }

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                SqlCommand cmd = new SqlCommand("usp_CrearTicket", cn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Titulo", reg.Titulo);
                cmd.Parameters.AddWithValue("@Descripcion", reg.Descripcion);
                cmd.Parameters.AddWithValue("@IdPrioridad", reg.IdPrioridad);
                cmd.Parameters.AddWithValue("@IdCategoria", reg.IdCategoria);

                await cn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
            }

            TempData["Success"] = "Ticket creado correctamente";
            return RedirectToAction("ListTickets");
        }

        //GET EDIT
        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var ticket = await buscarTicket(id);
            if (ticket == null)
                return NotFound();

            ViewBag.Prioridades = await listarPrioridades();
            ViewBag.Categorias = await listarCategorias();
            ViewBag.Estados = await listarEstados();

            return View(ticket);
        }

        //POST EDIT
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Ticket reg)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.Prioridades = await listarPrioridades();
                ViewBag.Categorias = await listarCategorias();
                ViewBag.Estados = await listarEstados();
                return View(reg);
            }

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                SqlCommand cmd = new SqlCommand("usp_ActualizarTicket", cn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@IdTicket", reg.IdTicket);
                cmd.Parameters.AddWithValue("@Titulo", reg.Titulo);
                cmd.Parameters.AddWithValue("@Descripcion", reg.Descripcion);
                cmd.Parameters.AddWithValue("@IdPrioridad", reg.IdPrioridad);
                cmd.Parameters.AddWithValue("@IdCategoria", reg.IdCategoria);

                await cn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
            }

            TempData["Success"] = "Ticket actualizado correctamente";
            return RedirectToAction("ListTickets");
        }

        //
    }
}