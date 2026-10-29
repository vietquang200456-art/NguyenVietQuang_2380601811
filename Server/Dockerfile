# Stage 1: Build & Publish
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies first (for better Docker layer caching)
COPY ["Server.csproj", "./"]
RUN dotnet restore "Server.csproj"

# Copy the rest of the source code and build
COPY . .
RUN dotnet publish "Server.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Configure ASP.NET Core environment and listening URL
ENV ASPNETCORE_URLS=http://+:5057
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 5057

# Copy published output from build stage
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "Server.dll"]

