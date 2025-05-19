class Carrera {
  const materias
  
  method materias() = materias
  
  method existeMateriaEnCarrera(materia) = materias.contains(materia)
}

class Materia {
  const carrera
  const estudiantesInscriptos = #{}
  const listaDeEspera = []
  const property requisitosInscripcion = new RequisitosMateria(
    numeroMaxCupo = 30,
    materiasNesesarias = #{}
  )
  
  method carrera() = carrera
  
  method estudiantesInscriptos() = estudiantesInscriptos
  
  method listaDeEspera() = listaDeEspera
  
  method materiasNesesarias() = requisitosInscripcion.materiasNesesarias()
  
  method agregarMateriaNesesaria(materia) {
    self.requisitosInscripcion().materiasNesesarias().add(materia)
  }
  
  method estaAnotadoEnMateria(estudiante) = estudiantesInscriptos.contains(
    estudiante
  )
  
  method interseccionMateriasInscripcion(
    estudiante
  ) = self.materiasNesesarias().intersection(estudiante.materiasAprobadas())
  
  method tieneMateriasNesesarias(
    estudiante
  ) = self.interseccionMateriasInscripcion(estudiante).equals(
    requisitosInscripcion.materiasNesesarias()
  )
  
  method noEstaAnotadoEnMateriaYCumpleRequisitos(
    estudiante
  ) = (not self.estaAnotadoEnMateria(
    estudiante
  )) && self.tieneMateriasNesesarias(estudiante)
  
  method inscribirEstudiante(estudiante) {
    if (requisitosInscripcion.hayCupo(self)) self.estudiantesInscriptos().add(
        estudiante
      )
    else self.listaDeEspera().add(estudiante)
  }
  
  method bajaEstudiante(estudiante) {
    estudiantesInscriptos.remove(estudiante)
    self.inscribeEstudianteSiHayEnListaDeEspera()
  }
  
  method inscribeEstudianteSiHayEnListaDeEspera() {
    if (self.hayEstudianteEnEspera()) self.inscribirEstudiante(
        self.listaDeEspera().first()
      )
    self.listaDeEspera().remove(listaDeEspera.first())
  }
  
  method hayEstudianteEnEspera() = not listaDeEspera.isEmpty()
}

class RequisitosMateria {
  var property numeroMaxCupo
  var property materiasNesesarias
  
  method hayCupo(
    materia
  ) = (materia.estudiantesInscriptos().size() + 1) <= numeroMaxCupo
}

class MateriaDeEstudiante {
  const estudiante
  const materia
  var property nota
  
  method materia() = materia
  
  method nota() = estudiante
}

class Estudiante {
  const property carreras = #{}
  const property materias = #{}
  
  method cantidadMateriasAprobadas() = materias.size()
  
  method materiasAprobadas() = materias.map({ materia => materia.materia() })
  
  method tieneAprobada(materia) = self.materiasAprobadas().contains(materia)
  
  method materiaConNota(materia, nota) = new MateriaDeEstudiante(
    estudiante = self,
    materia = materia,
    nota = nota
  )
  
  method promedio() = materias.average({ materia => materia.nota() })
  
  method registrarMateriaAprobada(materia, nota) {
    self.validarSiAproboMateria(materia)
    materias.add(self.materiaConNota(materia, nota))
  }
  
  method validarSiAproboMateria(materia) {
    if (self.tieneAprobada(materia)) self.error(
        "No se puede registrar, la materia se encuentra aprobada"
      )
  }
  
  method materiasDeTodasLasCarreras() = carreras.flatMap(
    { carrera => carrera.materias() }
  ).asSet()
  
  method materiasDondeEstoyInscripto() = self.materiasDeTodasLasCarreras().filter(
    { materia => materia.estudiantesInscriptos().contains(self) }
  )
  
  method materiasEnListaDeEspera() = self.materiasDeTodasLasCarreras().filter(
    { materia => materia.listaDeEspera().contains(self) }
  )
  
  method materiasDisponiblesParaInscripcion(carrera) {
    self.validarSiEstaCursando(carrera)
    return carrera.materias().filter(
      { materia => self.puedeInscribirse(materia) }
    )
  }
  
  method validarSiEstaCursando(carrera) {
    if (not self.carreras().contains(carrera)) self.error(
        "No hay materias disponibles ya que no estas cursando la carrera especificada"
      )
  }
  
  method existeMateriaEntreCarreras(
    materia
  ) = self.materiasDeTodasLasCarreras().contains(materia)
  
  method existeMateriaEnCarreraYNoEstaAprobada(
    materia
  ) = self.existeMateriaEntreCarreras(materia) && (not self.tieneAprobada(
    materia
  ))
  
  method puedeInscribirse(materia) = self.existeMateriaEnCarreraYNoEstaAprobada(
    materia
  ) && materia.noEstaAnotadoEnMateriaYCumpleRequisitos(self)
  
  method validarSiPuedeInscribir(materia) {
    if (not self.puedeInscribirse(materia)) self.error(
        "No se puede inscribir en la materia. Revisar las condiciones de la misma"
      )
  }
  
  method materiaParaInscripcion(
    materia
  ) = self.materiasDeTodasLasCarreras().find(materia)
  
  method inscribir(materia) {
    self.validarSiPuedeInscribir(materia)
    materia.inscribirEstudiante(self)
  }
}